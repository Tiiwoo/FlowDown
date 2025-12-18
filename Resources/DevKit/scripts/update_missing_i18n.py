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
    "%lld succeeded, %lld failed, %lld tests": {
        "de": "%lld erfolgreich, %lld fehlgeschlagen, %lld Tests",
        "es": "%lld correctas, %lld fallidas, %lld pruebas",
        "fr": "%lld réussis, %lld échoués, %lld tests",
        "ja": "%lld 件成功、%lld 件失敗、%lld 件のテスト",
        "ko": "%lld개 성공, %lld개 실패, %lld개 테스트",
        "zh-Hans": "%lld 成功，%lld 失败，%lld 项测试",
    },
    "Import Test Manifest": {
        "de": "Testmanifest importieren",
        "es": "Importar manifiesto de pruebas",
        "fr": "Importer le manifeste de test",
        "ja": "テストマニフェストをインポート",
        "ko": "테스트 매니페스트 가져오기",
        "zh-Hans": "导入测试清单",
    },
    "Exit": {
        "de": "Beenden",
        "es": "Salir",
        "fr": "Quitter",
        "ja": "終了",
        "ko": "종료",
        "zh-Hans": "退出",
    },
    "Exit Evaluation": {
        "de": "Evaluierung beenden",
        "es": "Salir de la evaluación",
        "fr": "Quitter l’évaluation",
        "ja": "評価を終了",
        "ko": "평가 종료",
        "zh-Hans": "退出评测",
    },
    "Exiting now will interrupt the running evaluation.": {
        "de": "Wenn du jetzt beendest, wird die laufende Evaluierung unterbrochen.",
        "es": "Salir ahora interrumpirá la evaluación en curso.",
        "fr": "Quitter maintenant interrompra l’évaluation en cours.",
        "ja": "今終了すると、実行中の評価が中断されます。",
        "ko": "지금 종료하면 실행 중인 평가가 중단됩니다.",
        "zh-Hans": "此时退出将中断正在运行的评测。",
    },
    "FlowDown Model Evaluation Result": {
        "de": "FlowDown Modellbewertungsergebnis",
        "es": "Resultado de evaluación del modelo de FlowDown",
        "fr": "Résultat d’évaluation du modèle FlowDown",
        "ja": "FlowDown モデル評価結果",
        "ko": "FlowDown 모델 평가 결과",
        "zh-Hans": "FlowDown 模型评测结果",
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

