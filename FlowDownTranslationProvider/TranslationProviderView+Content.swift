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
            ScrollView {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ZStack {
                Text("No models available for translation or the text is empty")
                    .underline()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
