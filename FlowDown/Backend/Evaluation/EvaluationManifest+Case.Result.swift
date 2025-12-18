//
//  EvaluationManifest+Case.Result.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import Foundation

extension EvaluationManifest.Suite.Case {
    class Result: Codable {
        var output: [EvaluationManifest.Suite.Case.Content]
        var outcome: Outcome

        init(
            output: [EvaluationManifest.Suite.Case.Content] = [],
            outcome: Outcome = .notDetermined,
        ) {
            self.output = output
            self.outcome = outcome
        }
    }
}

extension EvaluationManifest.Suite.Case.Result {
    enum Outcome: String, Codable {
        case notDetermined
        case processing
        case awaitingJudging
        case pass
        case fail
    }
}
