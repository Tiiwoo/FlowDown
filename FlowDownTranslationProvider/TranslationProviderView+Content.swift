//
//  TranslationProviderView+Content.swift
//  FlowDown
//
//  Created by qaq on 13/12/2025.
//

import ExtensionKit
import SwiftUI
import TranslationUIProvider

extension TranslationProviderView {
    @ViewBuilder
    var content: some View {
        if canTranslate {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !translationPlainResult.isEmpty {
                        Text(translationPlainResult)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(.numericText())
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.interactiveSpring, value: translationPlainResult)
            .animation(.interactiveSpring, value: translationSegmentedResult)
        } else {
            ZStack {
                Text("No models available for translation or the text is empty")
                    .underline()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
