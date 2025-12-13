//
//  TranslationProviderView+Footer.swift
//  FlowDown
//
//  Created by qaq on 13/12/2025.
//

import ExtensionKit
import SwiftUI
import TranslationUIProvider

extension TranslationProviderView {
    var footer: some View {
        VStack(spacing: 8) {
            if let translationError {
                Text(translationError.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .underline()
                    .transition(.opacity)
            }
            HStack {
                Button {
                    translate(language: nil)
                } label: {
                    IconButtonContainer(icon: "arrow.clockwise", foregroundColor: .primary)
                }
                Button {
                    UIPasteboard.general.string = translationPlainResult
                    context.finish(translation: nil)
                } label: {
                    IconButtonContainer(icon: "doc.on.doc", foregroundColor: .accent)
                }
            }
            .disabled(!canTranslate)
            .disabled(translationTask != nil)
        }
    }
}
