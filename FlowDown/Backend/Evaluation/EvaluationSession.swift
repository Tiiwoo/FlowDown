//
//  EvaluationSession.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import Foundation
import OSLog

class EvaluationSession: Codable, @unchecked Sendable {
    let id: UUID
    let createdAt: Date
    let modelIdentifier: ModelManager.ModelIdentifier
    let manifests: [EvaluationManifest]
    let maxConcurrentRequests: Int
    let shots: Int

    init(options: EvaluationOptions) {
        id = .init()
        createdAt = .init()
        modelIdentifier = options.modelIdentifier
        manifests = options.createFinalManifest()
        maxConcurrentRequests = options.options.maxConcurrentRequests
        shots = options.options.shots
    }
}

extension EvaluationSession {
    func resume() {}
}
