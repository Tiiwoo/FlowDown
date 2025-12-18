#!/usr/bin/env python3
"""
Update missing i18n translations in Localizable.xcstrings.
This script adds missing English localizations and fixes 'new' state translations.
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

# Populate this map with explicit translations when introducing new keys.
# Format: {"Key": {"zh-Hans": "示例", "es": "Ejemplo"}}
NEW_STRINGS: dict[str, dict[str, str]] = {
    "Delete All Evaluation Sessions": {
        "de": "Alle Bewertungssitzungen löschen",
        "es": "Eliminar todas las sesiones de evaluación",
        "fr": "Supprimer toutes les sessions d'évaluation",
        "ja": "すべての評価セッションを削除",
        "ko": "모든 평가 세션 삭제",
        "zh-Hans": "删除所有评估会话",
    },
    "Are you sure you want to delete all evaluation sessions?": {
        "de": "Möchten Sie wirklich alle Bewertungssitzungen löschen?",
        "es": "¿Seguro que quieres eliminar todas las sesiones de evaluación?",
        "fr": "Êtes-vous sûr de vouloir supprimer toutes les sessions d'évaluation ?",
        "ja": "すべての評価セッションを削除してもよろしいですか？",
        "ko": "모든 평가 세션을 삭제하시겠습니까?",
        "zh-Hans": "确定要删除所有评估会话吗？",
    },
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

