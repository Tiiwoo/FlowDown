import AppIntents
import Foundation

enum ShortcutsEntities {
    struct ModelEntity: AppEntity, Identifiable {
        static var typeDisplayRepresentation: TypeDisplayRepresentation {
            .init(name: LocalizedStringResource("Model", defaultValue: "Model"))
        }

        static var defaultQuery: ShortcutsEntities.ModelQuery { .init() }

        enum Source: String, Hashable {
            case local
            case cloud
            case apple

            var localizedDescription: LocalizedStringResource {
                switch self {
                case .local:
                    LocalizedStringResource("Local", defaultValue: "Local")
                case .cloud:
                    LocalizedStringResource("Cloud", defaultValue: "Cloud")
                case .apple:
                    LocalizedStringResource("Apple Intelligence", defaultValue: "Apple Intelligence")
                }
            }
        }

        let id: ModelManager.ModelIdentifier
        let displayName: String
        let source: Source

        var displayRepresentation: DisplayRepresentation {
            DisplayRepresentation(
                title: LocalizedStringResource(stringLiteral: displayName),
                subtitle: source.localizedDescription
            )
        }

        init(id: ModelManager.ModelIdentifier, displayName: String, source: Source) {
            self.id = id
            self.displayName = displayName
            self.source = source
        }
    }

    struct ModelQuery: EntityQuery {
        func entities(for identifiers: [ModelEntity.ID]) async throws -> [ModelEntity] {
            let available = await loadEntities()
            let identifierSet = Set(identifiers)
            return available.filter { identifierSet.contains($0.id) }
        }

        func suggestedEntities() async throws -> [ModelEntity] {
            let available = await loadEntities()
            return Array(available.prefix(6))
        }

        func entities(matching string: String) async throws -> [ModelEntity] {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return try await allEntities() }

            let lowercased = trimmed.lowercased()
            return await loadEntities().filter { entity in
                entity.displayName.lowercased().contains(lowercased) || entity.id.lowercased().contains(lowercased)
            }
        }

        func allEntities() async throws -> [ModelEntity] {
            await loadEntities()
        }

        private func loadEntities() async -> [ModelEntity] {
            await MainActor.run {
                let manager = ModelManager.shared
                var entities: [ModelManager.ModelIdentifier: ModelEntity] = [:]

                for model in manager.localModels.value {
                    let identifier = model.model_identifier
                    let name = manager.modelName(identifier: identifier)
                    entities[identifier] = ModelEntity(id: identifier, displayName: name, source: .local)
                }

                for model in manager.cloudModels.value {
                    let identifier = model.model_identifier
                    if entities[identifier] != nil { continue }
                    let name = manager.modelName(identifier: identifier)
                    entities[identifier] = ModelEntity(id: identifier, displayName: name, source: .cloud)
                }

                if #available(iOS 26.0, macCatalyst 26.0, *), AppleIntelligenceModel.shared.isAvailable {
                    let identifier = AppleIntelligenceModel.shared.modelIdentifier
                    entities[identifier] = ModelEntity(
                        id: identifier,
                        displayName: AppleIntelligenceModel.shared.modelDisplayName,
                        source: .apple
                    )
                }

                return entities.values
                    .sorted { lhs, rhs in
                        lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
                    }
            }
        }
    }
}

enum FlowDownShortcutError: LocalizedError {
    case emptyMessage
    case modelUnavailable
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            String(localized: "Empty message.")
        case .modelUnavailable:
            String(localized: "Unable to find the selected model.")
        case .emptyResponse:
            String(localized: "The model did not return any content.")
        }
    }
}
