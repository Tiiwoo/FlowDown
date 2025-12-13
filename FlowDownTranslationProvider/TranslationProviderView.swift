//
//  TranslationProviderView.swift
//  FlowDown
//
//  Created by qaq on 13/12/2025.
//

import ChatClientKit
import ExtensionKit
import Storage
import SwiftUI
import TranslationUIProvider

@MainActor
struct TranslationProviderView: View {
    @State var context: TranslationUIProviderContext
    let inputText: String

    let models: [CloudModel]
    @State var selectedModels: CloudModel.ID
    @State var translated: String = ""
    @State var translationTask: Task<Void, Never>? = nil
    @State var translationError: Error? = nil
    @State var translateOnAppear = true

    var canTranslate: Bool {
        guard models.map(\.id).contains(selectedModels),
              !inputText.isEmpty
        else { return false }
        return true
    }

    var model: CloudModel {
        models.first { $0.id == selectedModels } ?? .init(deviceId: "")
    }

    var currentLocaleDescription: String {
        Locale.current.identifier
    }

    init(context c: TranslationUIProviderContext) {
        context = c
        models = scanModels()
        _selectedModels = .init(initialValue: models.first?.id ?? "")
        if let input = c.inputText {
            var candidate = NSAttributedString(input)
                .string
                .trimmingCharacters(in: .whitespacesAndNewlines)
            while candidate.contains("\n\n") {
                candidate = candidate.replacingOccurrences(of: "\n\n", with: "\n")
            }
            inputText = candidate
        } else {
            inputText = ""
        }
    }

    var body: some View {
        VStack {
            header
            content
            footer
        }
        .padding()
        .animation(.spring, value: translationError?.localizedDescription)
        .onAppear {
            guard translateOnAppear else { return }
            translateOnAppear = false
            translate(language: nil)
        }
    }

    func translate(language: String?) {
        translationTask = .detached {
            do {
                try await translateEx(language: language)
            } catch {
                await MainActor.run { translationError = error }
            }
            await MainActor.run { translationTask = nil }
        }
    }

    func translateEx(language: String?) async throws {
        let targetLanguage = language ?? currentLocaleDescription
        let translationPrompt =
            """
            You are a professional translator. Your task is to translate the input text into \(targetLanguage).

            Strict Rules:
            1. **Line-by-Line Correspondence**: The translated output must have exactly the same number of lines as the source text. Do not merge or split lines.
            2. **Pure Output**: Output ONLY the translated result. No explanations, no "Here is the translation", no quotes.
            3. **Plain Text**: Do NOT use Markdown, XML tags, or any special formatting.
            4. **Empty Lines**: If a specific line in the source is empty, keep it empty in the translation.

            Input content is enclosed in <translation_content> tags below:
            <translation_content>
            \(inputText)
            </translation_content>
            """
    }
}
