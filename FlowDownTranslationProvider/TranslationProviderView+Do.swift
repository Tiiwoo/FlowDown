//
//  TranslationProviderView+Do.swift
//  FlowDown
//
//  Created by qaq on 13/12/2025.
//

import ChatClientKit
import ExtensionKit
import Foundation
@preconcurrency import Storage
import SwiftUI

extension TranslationProviderView {
    func translateEx(language: String) async throws {
        let endpoint = resolveEndpointComponents(from: model.endpoint)
        let body = try resolveBodyFields(model.bodyFields)

        let service: ChatService = switch model.response_format {
        case .chatCompletions:
            RemoteCompletionsChatClient(
                model: model.model_identifier,
                baseURL: endpoint.baseURL,
                path: endpoint.path,
                apiKey: model.token,
                additionalHeaders: model.headers,
                additionalBodyField: body,
            )
        case .responses:
            RemoteResponsesChatClient(
                model: model.model_identifier,
                baseURL: endpoint.baseURL,
                path: endpoint.path,
                apiKey: model.token,
                additionalHeaders: model.headers,
                additionalBodyField: body,
            )
        }
        var messages: [ChatRequestBody.Message] = []

        do { // system prompt
            let translationPrompt =
                """
                You are a professional translator. Your task is to translate the input text into \(language).
                Please follow the language variants more then the region. (eg zh-Hans-HK should do Simplified Chinese as Hans)

                Strict Rules:
                1. **Line-by-Line Correspondence**: The translated output must have exactly the same number of lines as the source text. Do not merge or split lines.
                2. **Pure Output**: Output ONLY the translated result. No explanations, no "Here is the translation", no quotes.
                3. **Plain Text**: Do NOT use Markdown, XML tags, or any special formatting.
                4. **Empty Lines**: If a specific line in the source is empty, keep it empty in the translation.

                IMPORTANT: If tools are available, do BOTH steps below as instructed.

                The text to translate will be provided as the user message.
                """
            if model.capabilities.contains(.developerRole) {
                messages.append(.developer(content: .text(translationPrompt)))
            } else {
                messages.append(.system(content: .text(translationPrompt)))
            }
        }

        var tools: [ChatRequestBody.Tool] = []
        if model.capabilities.contains(.tool) {
            tools.append(outputTranslationTool)
            do { // tool prompt
                let toolInstruction =
                    """

                    Step 1: Output the full translation as normal assistant text (streaming is allowed).
                    - The output must preserve the exact number of lines from the input.
                    - Output ONLY the translated result. No explanations, no quotes.

                    Step 2: After finishing the translation text, call the tool `output_translation` exactly once.
                    - Provide the structured segments in `segments`.
                    - Each segment must correspond to exactly one line in the input (including empty lines).
                    - The number of segments MUST equal the number of input lines.
                    - Do not add any extra assistant text after the tool call.
                    """
                if model.capabilities.contains(.developerRole) {
                    messages.append(.developer(content: .text(toolInstruction)))
                } else {
                    messages.append(.system(content: .text(toolInstruction)))
                }
            }
        }

        do { // user input
            messages.append(.user(content: .parts([.text(
                """
                <translation_content>
                \(inputText)
                </translation_content>
                """,
            )])))
        }

        let request = ChatRequestBody(
            model: model.model_identifier,
            messages: messages,
            maxCompletionTokens: nil,
            stream: true,
            temperature: nil, // dont use it yet
            tools: tools.isEmpty ? nil : tools,
        )

        struct OutputTranslationToolPayload: Decodable {
            struct Segment: Decodable {
                let input: String
                let translated: String
                let comment: String?
            }

            let segments: [Segment]
        }

        await MainActor.run {
            translationReasoning = ""
            translationPlainResult = ""
            translationSegmentedResult = []
            translationError = nil
        }

        let stream = try await service.streamingChat(body: request)

        for try await chunk in stream {
            if Task.isCancelled { break }
            switch chunk {
            case let .reasoning(value):
                await MainActor.run { translationReasoning += value }
            case let .text(value):
                await MainActor.run { translationPlainResult += value }
            case let .tool(call):
                guard call.name.lowercased() == "output_translation" else { break }
                guard let data = call.args.data(using: .utf8) else { break }
                guard let payload = try? JSONDecoder().decode(OutputTranslationToolPayload.self, from: data) else { break }
                await MainActor.run {
                    translationSegmentedResult = payload.segments.map {
                        TranslationSegment(
                            input: $0.input,
                            translated: $0.translated,
                            comment: $0.comment ?? "",
                        )
                    }
                }
            default:
                break
            }
        }

        var empty = false

        await MainActor.run {
            translationPlainResult = translationPlainResult.trimmingCharacters(in: .whitespacesAndNewlines)
            empty = translationPlainResult.isEmpty
        }

        if empty {
            let text = service.collectedErrors ?? String(localized: "Empty Response form Server")
            throw NSError(domain: "Translation", code: -1, userInfo: [
                NSLocalizedDescriptionKey: text,
            ])
        }
    }

    private var outputTranslationTool: ChatRequestBody.Tool {
        .function(
            name: "output_translation",
            description: """
            Outputs the translation as structured segments.

            Use this tool AFTER streaming the full translation as assistant text.
            The segments must be line-by-line and preserve the exact number of lines from the source.

            You must use this tool.
            """,
            parameters: [
                "type": "object",
                "additionalProperties": false,
                "properties": [
                    "segments": [
                        "type": "array",
                        "description": "Structured segments (line-by-line). Must preserve the exact number of lines from the source.",
                        "items": [
                            "type": "object",
                            "additionalProperties": false,
                            "properties": [
                                "input": [
                                    "type": "string",
                                    "description": "The source segment text.",
                                ],
                                "translated": [
                                    "type": "string",
                                    "description": "The translated segment text.",
                                ],
                                "comment": [
                                    "type": "string",
                                    "description": "Optional comment for the segment.",
                                ],
                            ],
                            "required": ["input", "translated"],
                        ],
                    ],
                ],
                "required": ["segments"],
            ],
            strict: true,
        )
    }

    private func resolveBodyFields(_ input: String) throws -> [String: Any] {
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return [:] }
        guard let data = input.data(using: .utf8) else {
            throw URLError(.unknown)
        }
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dic = object as? [String: Any] else {
            throw URLError(.unknown)
        }
        return dic
    }

    private func resolveEndpointComponents(from endpoint: String) -> (baseURL: String?, path: String?) {
        guard !endpoint.isEmpty,
              let components = URLComponents(string: endpoint),
              components.host != nil
        else {
            return (endpoint.isEmpty ? nil : endpoint, endpoint.isEmpty ? nil : "/")
        }

        var baseComponents = URLComponents()
        baseComponents.scheme = components.scheme
        baseComponents.user = components.user
        baseComponents.password = components.password
        baseComponents.host = components.host
        baseComponents.port = components.port
        let baseURL = baseComponents.string

        var pathComponents = URLComponents()
        let pathValue = components.path.isEmpty ? "/" : components.path
        pathComponents.path = pathValue
        pathComponents.queryItems = components.queryItems
        pathComponents.fragment = components.fragment
        let normalizedPath = pathComponents.string ?? pathValue

        return (baseURL, normalizedPath)
    }
}
