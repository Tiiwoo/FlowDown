//
//  EvaluationManifest+Case.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import Foundation

extension EvaluationManifest.Suite {
    class Case: Codable, Identifiable {
        var id: UUID = .init()

        var title: String
        var content: [Content]
        var verifier: [Verifier]
        var results: [Result]

        init(
            id: UUID = .init(),
            title: String,
            content: [Content],
            verifier: [Verifier],
            results: [Result] = [],
        ) {
            self.id = id
            self.title = title
            self.content = content
            self.verifier = verifier
            self.results = results
        }
    }
}
