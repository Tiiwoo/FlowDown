//
//  EvaluationManifest+Case.Content.swift
//  FlowDown
//
//  Created by qaq on 18/12/2025.
//

import ChatClientKit
import Foundation

extension EvaluationManifest.Suite.Case {
    enum ContentType: String, Codable, Equatable, Hashable, CaseIterable {
        case instruct
        case request
        case reasoning
        case reply
        case toolDefinition
        case toolRequest
        case toolResponse
    }

    class Content: Codable {
        let type: ContentType
        let textRepresentation: String?
        let toolRepresentation: ToolRepresentation?
        let imageRepresentation: Data?
        let audioRepresentation: Data?

        init(
            type: ContentType,
            textRepresentation: String? = nil,
            toolRepresentation: ToolRepresentation? = nil,
            imageRepresentation: Data? = nil,
            audioRepresentation: Data? = nil,
        ) {
            self.type = type
            self.textRepresentation = textRepresentation
            self.toolRepresentation = toolRepresentation
            self.imageRepresentation = imageRepresentation
            self.audioRepresentation = audioRepresentation
        }
    }

    class ToolRepresentation: Codable {
        let name: String
        let description: String
        let parameters: [String: AnyCodingValue]

        init(name: String, description: String, parameters: [String: AnyCodingValue]) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
}
