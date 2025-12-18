//
//  EvaluationManifest+Case.Verifier.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import ChatClientKit
import Foundation

extension EvaluationManifest.Suite.Case {
    enum Verifier: Codable, Equatable {
        // does not judge the result programmatically
        case open

        // match content trimming whitespace and newlines
        case match(pattern: String)
        case matchCaseInsensitive(pattern: String)
        case matchRegularExpression(pattern: String)

        // contains condition will search inside output for text
        case contains(pattern: String)
        case containsCaseInsensitive(pattern: String)

        // tool used
        case tool(parameter: String, value: AnyCodingValue)
    }
}

extension EvaluationManifest.Suite.Case.Verifier {
    var localizedDescription: String.LocalizationValue {
        switch self {
        case .open:
            "Open evaluation (no programmatic verification)"
        case let .match(pattern):
            "Match: \(pattern)"
        case let .matchCaseInsensitive(pattern):
            "Match (case-insensitive): \(pattern)"
        case let .matchRegularExpression(pattern):
            "Match (regex): \(pattern)"
        case let .contains(pattern):
            "Contains: \(pattern)"
        case let .containsCaseInsensitive(pattern):
            "Contains (case-insensitive): \(pattern)"
        case let .tool(parameter, value):
            "Tool parameter '\(parameter)' = \(String(describing: value))"
        }
    }
}
