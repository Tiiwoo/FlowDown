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
                VStack(alignment: .leading, spacing: 16) {
                    if !translationSegmentedResult.isEmpty {
                        ForEach(translationSegmentedResult) { segment in
                            TranslateSegmentView(segment: segment)
                        }
                        .transition(.opacity)
                    } else if !translationPlainResult.isEmpty {
                        Text(translationPlainResult)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(.numericText())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if translationTask == nil {
                        Text(String(localized: "(Empty Content)"))
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    if translationTask != nil {
                        ProgressView()
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ZStack {
                if inputText.isEmpty {
                    Text(String(localized: "Please select text to translate"))
                        .underline()
                } else if models.isEmpty {
                    Text(String(localized: "No cloud models available for translation. Please add cloud models in FlowDown app."))
                        .underline()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
