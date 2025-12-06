#!/usr/bin/env python3
"""
Update missing i18n translations (German preset).
Thin wrapper around shared i18n_tools to avoid duplicated logic.
"""

import sys

from i18n_tools import (
    DEFAULT_KEEP_LANGUAGES,
    default_file_path,
    load_strings,
    print_update_summary,
    save_strings,
    update_missing_translations,
)

# Add explicit translations for new keys when needed.
NEW_STRINGS: dict[str, dict[str, str]] = {}


if __name__ == "__main__":
    file_path = sys.argv[1] if len(sys.argv) > 1 else default_file_path()

    data = load_strings(file_path)
    counts = update_missing_translations(
        data,
        new_strings=NEW_STRINGS,
        keep_languages=DEFAULT_KEEP_LANGUAGES,
    )
    save_strings(file_path, data)

    print_update_summary(file_path, counts)
#!/usr/bin/env python3
"""
Update missing i18n translations in Localizable.xcstrings.
This script adds missing English localizations and fixes 'new' state translations.
"""

import json
import sys
import os

# you can modify this script to populate localization strings as needed
# just remember to remove the entries from NEW_STRINGS after committing
NEW_STRINGS: dict[str, dict[str, str]] = {
    "[%@] %@": {"de": "[%@] %@"},
    "%d. [%@] %@": {"de": "%d. [%@] %@"},
    "Apple Intelligence": {"de": "Apple Intelligence"},
    "Audio": {"de": "Audio"},
    "Cache": {"de": "Cache"},
    "Chat": {"de": "Chat"},
    "Cloud": {"de": "Cloud"},
    "Editor": {"de": "Editor"},
    "Flags": {"de": "Flags"},
    "Header": {"de": "Header"},
    "Logs": {"de": "Logs"},
    "Minimal": {"de": "Minimal"},
    "Name": {"de": "Name"},
    "Name: %@": {"de": "Name: %@"},
    "OK": {"de": "OK"},
    "Prompt": {"de": "Prompt"},
    "Start: %@": {"de": "Start: %@"},
    "Status: %@": {"de": "Status: %@"},
    "Support": {"de": "Support"},
    "System": {"de": "System"},
    "Text": {"de": "Text"},
    "Tool": {"de": "Tool"},
    "Tools": {"de": "Tools"},
}

# Languages we want to keep in the file (without auto-filling from English)
ADDITIONAL_LANGUAGES: set[str] = {"ja", "de", "fr", "es", "ko", "zh-Hans"}


def should_translate(entry: dict) -> bool:
    """Return whether this entry should be translated based on JSON flag."""
    return entry.get('shouldTranslate', True) is not False


def update_translations(file_path):
    """Update missing translations in the xcstrings file."""
    
    # Read the file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ File not found: {file_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ JSON decode error in {file_path}: {e}")
        sys.exit(1)
    
    strings = data['strings']

    # Ensure new strings exist with provided translations
    for key, translations in NEW_STRINGS.items():
        entry = strings.setdefault(key, {})
        if entry.get('shouldTranslate') is False:
            entry.pop('shouldTranslate', None)

        locs = entry.setdefault('localizations', {})
        locs.setdefault('en', {
            'stringUnit': {
                'state': 'translated',
                'value': key,
            }
        })

        for language, value in translations.items():
            locs[language] = {
                'stringUnit': {
                    'state': 'translated',
                    'value': value,
                }
            }

    # Determine all languages present in the file (excluding ones marked shouldTranslate=false)
    languages: set[str] = set()
    for value in strings.values():
        locs = value.get('localizations', {})
        for lang in locs.keys():
            languages.add(lang)

    # Ensure English is always part of the language set
    languages.add('en')

    # Count changes
    added_count = 0
    fixed_count = 0
    cleared_count = 0
    
    # Iterate through all strings
    for key, value in strings.items():
        translatable = should_translate(value)

        # Ensure dictionary exists for modifications
        if 'localizations' not in value:
            value['localizations'] = {}

        locs = value['localizations']

        # Check if 'en' localization is missing
        if 'en' not in locs:
            locs['en'] = {
                'stringUnit': {
                    'state': 'translated',
                    'value': key
                }
            }
            added_count += 1

        # Ensure English localization is properly marked
        en_loc = locs['en']
        en_string_unit = en_loc.setdefault('stringUnit', {})
        if en_string_unit.get('state') == 'new':
            if not en_string_unit.get('value', '').strip():
                en_string_unit['value'] = key
            en_string_unit['state'] = 'translated'
            fixed_count += 1
        english_value = en_string_unit.get('value', key)

        # For non-English languages:
        # - if missing -> create empty placeholder
        # - if same as English -> clear to empty (state=new)
        # - do NOT copy English as fallback
        # - for non-translatable entries, also clear other languages
        for language in languages:
            if language == 'en':
                continue

            string_unit = locs.get(language, {}).get('stringUnit')
            current_value = string_unit.get('value', '').strip() if string_unit else ''
            current_state = string_unit.get('state') if string_unit else None

            if not translatable:
                if language not in locs or current_value:
                    locs[language] = {'stringUnit': {'state': 'new', 'value': ''}}
                    cleared_count += 1
                continue

            # If missing localization, create an empty placeholder
            if language not in locs:
                locs[language] = {
                    'stringUnit': {
                        'state': 'new',
                        'value': ''
                    }
                }
                cleared_count += 1
                continue

            # If value is empty or matches English, try to keep explicit NEW_STRINGS translation; otherwise clear
            if not current_value or current_value == english_value:
                if key in NEW_STRINGS and language in NEW_STRINGS[key]:
                    locs[language]['stringUnit'] = {
                        'state': 'translated',
                        'value': NEW_STRINGS[key][language]
                    }
                else:
                    locs[language]['stringUnit'] = {
                        'state': 'new',
                        'value': ''
                    }
                    cleared_count += 1
            else:
                if current_state == 'new' and current_value:
                    locs[language]['stringUnit']['state'] = 'translated'
    
    # Write the updated file
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"✅ Successfully updated {file_path}")
        print(f"   - Added {added_count} missing English localizations")
        print(f"   - Fixed {fixed_count} 'new' state translations")
        print(f"   - Cleared {cleared_count} fallback/localizations (non-English)")
        return True
    except Exception as e:
        print(f"❌ Error writing file: {e}")
        sys.exit(1)


if __name__ == '__main__':
    # Default path to the Localizable.xcstrings file
    default_file_path = os.path.join(
        os.path.dirname(__file__),
        '..', '..', '..',
        'FlowDown',
        'Resources',
        'Localizable.xcstrings'
    )
    
    # Allow overriding the file path via command line argument
    file_path = sys.argv[1] if len(sys.argv) > 1 else default_file_path
    
    print(f"📝 Updating translations in: {file_path}")
    update_translations(file_path)
