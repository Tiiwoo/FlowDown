#!/usr/bin/env python3
"""
Update missing i18n translations (Spanish preset).
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

NEW_STRINGS: dict[str, dict[str, str]] = {
    "[%@] %@": {"es": "[%@] %@"},
    "%d. [%@] %@": {"es": "%d. [%@] %@"},
    "Apple Intelligence": {"es": "Apple Intelligence"},
    "Audio": {"es": "Audio"},
    "Chat": {"es": "Chat"},
    "Editor": {"es": "Editor"},
    "Endpoint": {"es": "Endpoint"},
    "Error": {"es": "Error"},
    "General": {"es": "General"},
    "Local": {"es": "Local"},
    "OK": {"es": "OK"},
}


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

