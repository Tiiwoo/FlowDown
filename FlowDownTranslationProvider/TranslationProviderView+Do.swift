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
    func translateEx(language: String?) async throws {
        let targetLanguage = language ?? currentLocaleDescription
        let translationPrompt =
            """
            You are a professional translator. Your task is to translate the input text into \(targetLanguage).

            Strict Rules:
            1. **Line-by-Line Correspondence**: The translated output must have exactly the same number of lines as the source text. Do not merge or split lines.
            2. **Pure Output**: Output ONLY the translated result. No explanations, no "Here is the translation", no quotes.
            3. **Plain Text**: Do NOT use Markdown, XML tags, or any special formatting.
            4. **Empty Lines**: If a specific line in the source is empty, keep it empty in the translation.

            Input content is enclosed in <translation_content> tags below:
            <translation_content>
            \(inputText)
            </translation_content>
            """

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
        if model.capabilities.contains(.developerRole) {
            messages.append(.developer(content: .text(translationPrompt)))
        } else {
            messages.append(.system(content: .text(translationPrompt)))
        }
        var tools: [ChatRequestBody.Tool] = []
        if model.capabilities.contains(.tool) {}
        let request = ChatRequestBody(
            model: model.model_identifier,
            messages: messages,
            maxCompletionTokens: nil,
            stream: true,
            temperature: nil, // dont use it yet
            tools: tools.isEmpty ? nil : tools,
        )
        
        let stream = try await service.streamingChat(request)
        for try await chunk in stream {
                
        }
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
