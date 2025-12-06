//
//  CloudModelResponseFormat+Display.swift
//  FlowDown
//
//  Created by GPT-5 Codex on 2025/12/06.
//

import Foundation
import Storage

extension CloudModelResponseFormat {
    var localizedTitle: String {
        switch self {
        case .chatCompletions:
            String(localized: "Chat Completions Format")
        case .responses:
            String(localized: "Responses Format")
        }
    }

    var localizedDescription: String {
        switch self {
        case .chatCompletions:
            String(localized: "Use OpenAI-compatible chat completions.") + " " + "(POST /v1/chat/completions)"
        case .responses:
            String(localized: "Use OpenAI-compatible chat response format.") + " " + "(POST /v1/responses)"
        }
    }

    var symbolName: String {
        switch self {
        case .chatCompletions:
            "1.circle"
        case .responses:
            "2.circle"
        }
    }
}
