//
//  EvaluationSession.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import ChatClientKit
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

    private enum CodingKeys: String, CodingKey {
        case id, createdAt, modelIdentifier, manifests, maxConcurrentRequests, shots
    }

    private var runningTask: Task<Void, Never>?
}

extension EvaluationSession {
    func resume() {
        runningTask = Task {
            await startEvaluation()
        }
    }

    func stop() {
        runningTask?.cancel()
        // Run save in a detached task or synchronous if possible, but manager likely async or safe
        // We can just trigger a save. Since we are cancelling, the session state (results)
        // will be preserved as they are updated in real-time.
        // We might want to mark any 'processing' items as 'notDetermined' so they are picked up next time?
        // Or just leave them, startEvaluation handles it.
        try? EvaluationSessionManager.shared.save(self)
    }

    private func startEvaluation() async {
        // Flatten all cases
        var allCases: [EvaluationManifest.Suite.Case] = []
        for manifest in manifests {
            for suite in manifest.suites {
                allCases.append(contentsOf: suite.cases)
            }
        }

        // Prepare cases for execution
        // We only want to run cases that are NOT completed.
        var casesToRun: [EvaluationManifest.Suite.Case] = []
        for caseItem in allCases {
            let currentOutcome = caseItem.results.last?.outcome ?? .notDetermined
            switch currentOutcome {
            case .pass, .fail, .awaitingJudging:
                // Already done, skip
                continue
            case .processing, .notDetermined:
                // Needs running. Reset processing to notDetermined for clean start
                if caseItem.results.isEmpty {
                    caseItem.results.append(.init(outcome: .notDetermined))
                } else {
                    caseItem.results[caseItem.results.count - 1].outcome = .notDetermined
                }
                casesToRun.append(caseItem)
            }
        }

        await withTaskGroup(of: Void.self) { group in
            let casesChannel = AsyncStream<EvaluationManifest.Suite.Case> { continuation in
                for caseItem in casesToRun {
                    continuation.yield(caseItem)
                }
                continuation.finish()
            }

            for _ in 0 ..< self.maxConcurrentRequests {
                group.addTask {
                    for await caseItem in casesChannel {
                        if Task.isCancelled { return }
                        await self.evaluate(caseItem)
                    }
                }
            }
        }

        let id = id
        if !Task.isCancelled {
            logger.info("Evaluation session \(id) completed")
        } else {
            logger.info("Evaluation session \(id) stopped")
        }

        try? EvaluationSessionManager.shared.save(self)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .evaluationSessionDidUpdate, object: self)
        }
    }

    private func evaluate(_ caseItem: EvaluationManifest.Suite.Case) async {
        await updateResult(for: caseItem, outcome: .processing)

        var attempts = 0
        var stop = false

        while attempts < shots, !stop {
            attempts += 1
            if attempts > 1 {
                // Retry logic if needed
            }

            let outcome = await performSingleShot(caseItem)

            switch outcome {
            case .pass, .awaitingJudging:
                stop = true
                await updateResult(for: caseItem, outcome: outcome)
            case .fail:
                if attempts >= shots {
                    await updateResult(for: caseItem, outcome: .fail)
                }
            default:
                break
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .evaluationSessionDidUpdate, object: self)
            }
        }
    }

    private func updateResult(for caseItem: EvaluationManifest.Suite.Case, outcome: EvaluationManifest.Suite.Case.Result.Outcome) async {
        guard let result = caseItem.results.last else { return }
        result.outcome = outcome
    }

    private func performSingleShot(_ caseItem: EvaluationManifest.Suite.Case) async -> EvaluationManifest.Suite.Case.Result.Outcome {
        var messages: [ChatRequestBody.Message] = []
        var tools: [ChatRequestBody.Tool] = []

        for content in caseItem.content {
            switch content.type {
            case .instruct:
                if let text = content.textRepresentation {
                    messages.append(.system(content: .text(text)))
                }
            case .request:
                if let text = content.textRepresentation {
                    messages.append(.user(content: .text(text)))
                }
            case .toolDefinition:
                if let toolRep = content.toolRepresentation,
                   let tool = convertToTool(toolRep)
                {
                    tools.append(tool)
                }
            case .reasoning:
                if let text = content.textRepresentation {
                    messages.append(.assistant(content: nil, toolCalls: nil, reasoning: text))
                }
            case .reply:
                if let text = content.textRepresentation {
                    messages.append(.assistant(content: .text(text), toolCalls: nil, reasoning: nil))
                }
            default:
                break
            }
        }

        do {
            let response = try await ModelManager.shared.infer(
                with: modelIdentifier,
                input: messages,
                tools: tools.isEmpty ? nil : tools,
            )

            // Save output to result
            if let result = caseItem.results.last {
                var output: [EvaluationManifest.Suite.Case.Content] = []
                if !response.reasoning.isEmpty {
                    output.append(.init(type: .reasoning, textRepresentation: response.reasoning))
                }
                if !response.text.isEmpty {
                    output.append(.init(type: .reply, textRepresentation: response.text))
                }
                for toolMsg in response.tools {
                    let toolRep: EvaluationManifest.Suite.Case.ToolRepresentation? = if
                        let data = toolMsg.args.data(using: .utf8),
                        let params = try? JSONDecoder().decode([String: AnyCodingValue].self, from: data)
                    {
                        .init(name: toolMsg.name, description: "", parameters: params)
                    } else {
                        .init(name: toolMsg.name, description: "", parameters: [:])
                    }
                    output.append(.init(type: .toolRequest, textRepresentation: toolMsg.args, toolRepresentation: toolRep))
                }
                result.output = output
            }

            return verify(response: response, verifiers: caseItem.verifier)
        } catch {
            return .fail
        }
    }

    private func convertToTool(_ rep: EvaluationManifest.Suite.Case.ToolRepresentation) -> ChatRequestBody.Tool? {
        .function(
            name: rep.name,
            description: rep.description,
            parameters: rep.parameters,
            strict: false,
        )
    }

    func verify(response: ChatResponse, verifiers: [EvaluationManifest.Suite.Case.Verifier]) -> EvaluationManifest.Suite.Case.Result.Outcome {
        // Check for manual verification requirement
        let requiresManualJudgment = verifiers.contains(where: { if case .open = $0 { return true }; return false })

        // Check automatic verifiers
        var automaticPass = true

        for verifier in verifiers {
            switch verifier {
            case .open:
                continue
            case let .match(pattern):
                if response.text.trimmingCharacters(in: .whitespacesAndNewlines) != pattern { automaticPass = false }
            case let .matchCaseInsensitive(pattern):
                if response.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != pattern.lowercased() { automaticPass = false }
            case let .contains(pattern):
                if !response.text.contains(pattern) { automaticPass = false }
            case let .containsCaseInsensitive(pattern):
                if !response.text.lowercased().contains(pattern.lowercased()) { automaticPass = false }
            case let .matchRegularExpression(pattern):
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    let range = NSRange(location: 0, length: response.text.utf16.count)
                    if regex.firstMatch(in: response.text, options: [], range: range) == nil {
                        automaticPass = false
                    }
                } else {
                    automaticPass = false
                }
            case let .tool(parameter, value):
                let encoder = JSONEncoder()
                guard let valueData = try? encoder.encode(value),
                      let valueStr = String(data: valueData, encoding: .utf8)
                else {
                    automaticPass = false
                    continue
                }

                let matching = response.tools.contains(where: { toolReq in
                    guard let argsData = toolReq.args.data(using: String.Encoding.utf8),
                          let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any]
                    else {
                        return false
                    }
                    if let paramValue = args[parameter] {
                        return String(describing: paramValue) == valueStr.replacingOccurrences(of: "\"", with: "")
                    }
                    return false
                })
                if !matching { automaticPass = false }
            }

            if !automaticPass { break }
        }

        if !automaticPass { return .fail }
        if requiresManualJudgment { return .awaitingJudging }
        return .pass
    }
}

extension Notification.Name {
    static let evaluationSessionDidUpdate = Notification.Name("evaluationSessionDidUpdate")
}
