//
//  EvaluationSessionTests.swift
//  FlowDownUnitTests
//
//  Created by qaq on 18/12/2025.
//

@testable import ChatClientKit
@testable import FlowDown
import XCTest

class EvaluationSessionTests: XCTestCase {
    var session: EvaluationSession!

    override func setUp() {
        super.setUp()
        // Provide dummy options if needed.
        let emptyManifest = EvaluationManifest(title: "Test", description: "", suites: [])
        let options = EvaluationOptions(modelIdentifier: "test-model", manifesets: [emptyManifest])
        session = EvaluationSession(options: options)
    }

    func testVerifyMatch() {
        let response = ChatResponse(reasoning: "", text: "Hello World", images: [], tools: [])
        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.match(pattern: "Hello World")]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.pass)
    }

    func testVerifyMatchFail() {
        let response = ChatResponse(reasoning: "", text: "Hello World", images: [], tools: [])
        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.match(pattern: "Hello")]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.fail)
    }

    func testVerifyContains() {
        let response = ChatResponse(reasoning: "", text: "The quick brown fox", images: [], tools: [])
        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.contains(pattern: "brown")]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.pass)
    }

    func testVerifyRegex() {
        let response = ChatResponse(reasoning: "", text: "Order ID: 12345", images: [], tools: [])
        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.matchRegularExpression(pattern: #"Order ID: \d+"#)]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.pass)
    }

    func testVerifyOpen() {
        let response = ChatResponse(reasoning: "", text: "Some creative text", images: [], tools: [])
        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.open]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.awaitingJudging)
    }

    func testVerifyTool() {
        let toolCall = ToolRequest(id: "call_1", name: "calculator", args: #"{"a": 1, "b": 2}"#)
        let response = ChatResponse(reasoning: "", text: "", images: [], tools: [toolCall])

        let verifiers: [EvaluationManifest.Suite.Case.Verifier] = [.tool(parameter: "a", value: 1)]

        let outcome = session.verify(response: response, verifiers: verifiers)
        XCTAssertEqual(outcome, EvaluationManifest.Suite.Case.Result.Outcome.pass)
    }

    func testExcludedSuitesAreNotIncludedInSessionManifests() {
        let caseA = EvaluationManifest.Suite.Case(title: "A", content: [], verifier: [])
        let caseB = EvaluationManifest.Suite.Case(title: "B", content: [], verifier: [])

        let suite1 = EvaluationManifest.Suite(title: "Suite 1", description: "", cases: [caseA])
        let suite2 = EvaluationManifest.Suite(title: "Suite 2", description: "", cases: [caseB])

        let manifest = EvaluationManifest(title: "Manifest", description: "", suites: [suite1, suite2])
        let options = EvaluationOptions(
            modelIdentifier: "test-model",
            manifesets: [manifest],
            excludedSuites: [suite2.id],
            excludedCases: [],
            options: .init(maxConcurrentRequests: 1, shots: 1),
        )

        let newSession = EvaluationSession(options: options)
        XCTAssertEqual(newSession.manifests.count, 1)
        XCTAssertEqual(newSession.manifests.first?.suites.count, 1)
        XCTAssertEqual(newSession.manifests.first?.suites.first?.id, suite1.id)
    }
}
