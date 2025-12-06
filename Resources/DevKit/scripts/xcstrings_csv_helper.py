#!/usr/bin/env python3
"""
Export untranslated strings to CSV and apply translations back into
Localizable.xcstrings. Designed to keep edits out of the giant JSON file.

Usage:
  Export up to 20 rows with missing translations (any language) to .build/xcstrings-untranslated.csv
    python3 Resources/DevKit/scripts/xcstrings_csv_helper.py export [path/to/Localizable.xcstrings]
  Apply translations from CSV back into the xcstrings file (all language columns)
    python3 Resources/DevKit/scripts/xcstrings_csv_helper.py apply [path/to/xcstrings-untranslated.csv] [path/to/Localizable.xcstrings]

The CSV columns are: key,en,<lang1>,<lang2>,...,reason
Only non-empty language cells are applied.
"""

import argparse
import csv
import json
import os
import sys
from typing import Dict, List, Tuple

# Strings that intentionally stay identical across locales
EXCEPTIONS = {
    "Discord",
    "FlowDown",
    "GitHub",
}

# Default export limit
DEFAULT_LIMIT = 20


def repo_root() -> str:
    """Return repository root based on this file location."""
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def default_xcstrings_path() -> str:
    """Default path to Localizable.xcstrings."""
    return os.path.join(repo_root(), "FlowDown", "Resources", "Localizable.xcstrings")


def default_csv_path() -> str:
    """Default CSV output/input path inside .build."""
    build_dir = os.path.join(repo_root(), ".build")
    os.makedirs(build_dir, exist_ok=True)
    return os.path.join(build_dir, "xcstrings-untranslated.csv")


def load_xcstrings(path: str) -> Dict:
    """Load xcstrings JSON data."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"❌ File not found: {path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ JSON decode error in {path}: {e}")
        sys.exit(1)


def collect_languages(strings: Dict) -> List[str]:
    """Collect all languages present in the file (excluding duplicates), sorted with en first."""
    languages = set()
    for value in strings.values():
        locs = value.get("localizations", {})
        languages.update(locs.keys())
    # Ensure English is present
    languages.add("en")
    # Sort with en first, then alphabetically
    ordered = ["en"] + sorted(lang for lang in languages if lang != "en")
    return ordered


def detect_untranslated(strings: Dict, languages: List[str], limit: int) -> List[Tuple[str, Dict[str, str], str]]:
    """
    Return up to `limit` items needing translation in any language.

    Each tuple: (key, values_by_lang, reason)
    """
    rows: List[Tuple[str, Dict[str, str], str]] = []

    for key in sorted(strings.keys()):
        entry = strings[key]
        if not entry.get("shouldTranslate", True):
            continue

        locs = entry.get("localizations", {})
        values: Dict[str, str] = {}
        reasons: List[str] = []

        # Populate existing values for all languages (default empty)
        for lang in languages:
            unit = locs.get(lang, {}).get("stringUnit", {}) if lang in locs else {}
            values[lang] = unit.get("value", "") if unit else ""

        en_value = values.get("en") or key

        # Detect per-language issues (skip en)
        for lang in languages:
            if lang == "en":
                continue

            unit = locs.get(lang, {}).get("stringUnit", {}) if lang in locs else {}
            value = unit.get("value", "") if unit else ""
            state = unit.get("state")

            reason = None
            if lang not in locs:
                reason = "missing localization"
            elif not value.strip():
                reason = "empty value"
            elif state and state != "translated":
                reason = f"state={state}"
            elif key not in EXCEPTIONS and value == en_value:
                reason = "matches en"

            if reason:
                reasons.append(f"{lang}: {reason}")

        if reasons:
            rows.append((key, values, "; ".join(reasons)))
            if len(rows) >= limit:
                break

    return rows


def export_to_csv(xcstrings_path: str, csv_path: str, limit: int) -> None:
    """Export untranslated strings to CSV."""
    data = load_xcstrings(xcstrings_path)
    strings = data.get("strings", {})

    languages = collect_languages(strings)
    rows = detect_untranslated(strings, languages, limit)
    if not rows:
        print("✅ No untranslated strings found.")
        return

    headers = ["key"] + languages + ["reason"]

    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        for key, values, reason in rows:
            row = [key] + [values.get(lang, "") for lang in languages] + [reason]
            writer.writerow(row)

    print(f"✅ Exported {len(rows)} rows to {csv_path}")
    print("   Edit any language columns and run apply to import translations.")


def apply_from_csv(csv_path: str, xcstrings_path: str) -> None:
    """Apply translated CSV rows back into the xcstrings file."""
    if not os.path.exists(csv_path):
        print(f"❌ CSV file not found: {csv_path}")
        sys.exit(1)

    data = load_xcstrings(xcstrings_path)
    strings = data.get("strings", {})

    applied = 0
    skipped = 0

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        languages = [c for c in fieldnames if c not in {"key", "reason"}]

        if "en" not in languages:
            languages.insert(0, "en")

        for row in reader:
            key = row.get("key", "").strip()
            if not key:
                skipped += 1
                continue

            entry = strings.setdefault(key, {"localizations": {}})
            if entry.get("shouldTranslate") is False:
                skipped += 1
                continue

            locs = entry.setdefault("localizations", {})

            # Ensure English exists to anchor the record
            en_value = (row.get("en") or "").strip() or locs.get("en", {}).get("stringUnit", {}).get("value", "") or key
            locs.setdefault(
                "en",
                {
                    "stringUnit": {
                        "state": "translated",
                        "value": en_value,
                    }
                },
            )

            updated_any = False
            for lang in languages:
                if lang in {"key", "en", "reason"}:
                    continue
                value = (row.get(lang) or "").strip()
                if not value:
                    continue

                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": value,
                    }
                }
                updated_any = True

            if updated_any:
                applied += 1
            else:
                skipped += 1

    if applied == 0:
        print(f"⚠️  No translations applied (skipped {skipped} rows).")
        return

    with open(xcstrings_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ Applied {applied} translations to {xcstrings_path}")
    if skipped:
        print(f"⚠️  Skipped {skipped} rows (empty zh-Hans or shouldTranslate=false).")


def main():
    parser = argparse.ArgumentParser(description="CSV helper for Localizable.xcstrings translations.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    export_parser = subparsers.add_parser("export", help="Export untranslated strings to CSV")
    export_parser.add_argument(
        "xcstrings",
        nargs="?",
        default=default_xcstrings_path(),
        help="Path to Localizable.xcstrings (defaults to FlowDown/Resources/Localizable.xcstrings)",
    )
    export_parser.add_argument(
        "--limit",
        type=int,
        default=DEFAULT_LIMIT,
        help=f"Maximum rows to export (default: {DEFAULT_LIMIT})",
    )
    export_parser.add_argument(
        "--out",
        default=default_csv_path(),
        help="CSV output path (defaults to .build/xcstrings-untranslated.csv)",
    )

    apply_parser = subparsers.add_parser("apply", help="Apply translations from CSV")
    apply_parser.add_argument(
        "csv",
        nargs="?",
        default=default_csv_path(),
        help="Path to CSV file (defaults to .build/xcstrings-untranslated.csv)",
    )
    apply_parser.add_argument(
        "xcstrings",
        nargs="?",
        default=default_xcstrings_path(),
        help="Path to Localizable.xcstrings to update",
    )

    args = parser.parse_args()

    if args.command == "export":
        export_to_csv(args.xcstrings, args.out, args.limit)
    elif args.command == "apply":
        apply_from_csv(args.csv, args.xcstrings)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()

