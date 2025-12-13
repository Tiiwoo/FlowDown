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
    @State var translationPlainResult: String = ""
    @State var translationSegmentedResult: [TranslationSegment] = []

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
}
