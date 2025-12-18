//
//  ModelController+Bar.swift
//  FlowDown
//
//  Created by 秋星桥 on 1/27/25.
//

import AlertController
import ConfigurableKit
import MLX
import Storage
import UIKit
import UniformTypeIdentifiers

extension SettingController.SettingContent.ModelController {
    private func createCloudModelMenuItems() -> [UIMenuElement] {
        [
            UIMenu(
                title: String(localized: "pollinations.ai (free)"),
                image: .init(systemName: "network"),
                children: [
                    UIDeferredMenuElement.uncached { [weak self] completion in
                        Task { @MainActor in
                            do {
                                let models = try await PollinationsService.shared.fetchAvailableModels()
                                let actions = models.map { pollinationsModel in
                                    UIAction(
                                        title: pollinationsModel.name,
                                        image: .init(systemName: "network"),
                                    ) { [weak self] _ in
                                        let cloudModel = PollinationsService.shared.createCloudModel(from: pollinationsModel)
                                        _ = ModelManager.shared.newCloudModel(profile: cloudModel)
                                        Indicator.present(
                                            title: "Model Added",
                                            preset: .done,
                                            referencingView: self?.view,
                                        )
                                    }
                                }
                                let menu = UIMenu(
                                    options: [.displayInline],
                                    children: actions,
                                )
                                completion([menu])
                            } catch {
                                let errorAction = UIAction(
                                    title: String(localized: "Failed to load models"),
                                    image: .init(systemName: "exclamationmark.triangle"),
                                ) { _ in }
                                errorAction.attributes = .disabled
                                completion([errorAction])
                            }
                        }
                    },
                ],
            ),
            UIAction(
                title: String(localized: "Empty Model"),
                image: .init(systemName: "square.dashed"),
            ) { [weak self] _ in
                guard let self else { return }
                let profile = CloudModel(deviceId: Storage.deviceId)
                _ = ModelManager.shared.newCloudModel(profile: profile)
                let controller = CloudModelEditorController(identifier: profile.id)
                navigationController?.pushViewController(controller, animated: true)
            },
        ]
    }

    private func createLocalModelMenuItems() -> [UIMenuElement] {
        [
            UIAction(
                title: String(localized: "Download @ Hugging Face"),
                image: .init(systemName: "icloud.and.arrow.down"),
            ) { [weak self] _ in
                guard MLX.GPU.isSupported else {
                    let alert = AlertViewController(
                        title: "Unsupported",
                        message: "Your device does not support MLX.",
                    ) { context in
                        context.allowSimpleDispose()
                        context.addAction(title: "OK", attribute: .accent) {
                            context.dispose()
                        }
                    }
                    self?.present(alert, animated: true)
                    return
                }
                guard let nav = self?.navigationController else { return }
                nav.pushViewController(HubModelDownloadController(), animated: true)
            },
            UIAction(
                title: String(localized: "Connect @ OLLAMA"),
                image: .init(systemName: "cable.connector.horizontal"),
            ) { [weak self] _ in
                let profile = CloudModel(deviceId: Storage.deviceId)
                _ = ModelManager.shared.newCloudModel(profile: profile)
                let controller = CloudModelEditorController(identifier: profile.id)
                self?.navigationController?.pushViewController(controller, animated: true)
            },
            UIAction(
                title: String(localized: "Connect @ LM Studio"),
                image: .init(systemName: "cable.connector.horizontal"),
            ) { [weak self] _ in
                let profile = CloudModel(deviceId: Storage.deviceId)
                _ = ModelManager.shared.newCloudModel(profile: profile)
                let controller = CloudModelEditorController(identifier: profile.id)
                self?.navigationController?.pushViewController(controller, animated: true)
            },
        ]
    }

    func createAddModelMenuItems() -> [UIMenuElement] {
        [
            UIMenu(
                title: String(localized: "Cloud Model"),
                options: [.displayInline],
                children: createCloudModelMenuItems(),
            ),
            UIMenu(
                title: String(localized: "Local Model"),
                options: [.displayInline],
                children: createLocalModelMenuItems(),
            ),
            UIMenu(
                title: String(localized: "Import Model"),
                options: [.displayInline],
                children: [
                    UIAction(
                        title: String(localized: "Import from File"),
                        image: .init(systemName: "arrow.down.doc"),
                    ) { [weak self] _ in
                        guard let self else { return }
                        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
                            .zip, .propertyList, UTType(filenameExtension: "fdmodel") ?? .data,
                        ], asCopy: true)
                        picker.title = String(localized: "Import Model")
                        picker.delegate = self
                        picker.allowsMultipleSelection = true
                        picker.modalPresentationStyle = .formSheet
                        present(picker, animated: true)
                    },
                ],
            ),
        ]
    }

    func createFilterMenuItems() -> [UIMenuElement] {
        [
            UIAction(
                title: String(localized: "Show Local Models"),
                state: showLocalModels ? .on : .off,
            ) { [weak self] _ in
                self?.showLocalModels.toggle()
            },
            UIAction(
                title: String(localized: "Show Cloud Models"),
                state: showCloudModels ? .on : .off,
            ) { [weak self] _ in
                self?.showCloudModels.toggle()
            },
        ]
    }

    // Shared menu elements for a specific model row. Extracted so context menus
    // and any toolbar / accessory menus can reuse the same actions.
    func createModelMenuElements(for itemIdentifier: ModelViewModel) -> [UIMenuElement] {
        var actions: [UIMenuElement] = []

        switch itemIdentifier.type {
        case .local:
            break
        case .cloud:
            actions.append(UIAction(
                title: String(localized: "Export Model"),
                image: UIImage(systemName: "square.and.arrow.up"),
            ) { [weak self] _ in
                self?.exportModel(itemIdentifier)
            })
            actions.append(UIAction(
                title: String(localized: "Duplicate"),
                image: UIImage(systemName: "doc.on.doc"),
            ) { _ in
                switch itemIdentifier.type {
                case .local:
                    preconditionFailure()
                case .cloud:
                    let newIdentifier = UUID().uuidString
                    ModelManager.shared.editCloudModel(identifier: itemIdentifier.identifier) {
                        $0.update(\.objectId, to: newIdentifier)
                        $0.update(\.model_identifier, to: "")
                        $0.update(\.creation, to: $0.modified)
                    }
                    guard let model = ModelManager.shared.cloudModel(identifier: newIdentifier) else {
                        return
                    }
                    ModelManager.shared.insertCloudModel(model)
                }
            })
        }
        actions.append(UIAction(
            title: String(localized: "Delete"),
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
        ) { _ in
            switch itemIdentifier.type {
            case .local:
                ModelManager.shared.removeLocalModel(identifier: itemIdentifier.identifier)
            case .cloud:
                ModelManager.shared.removeCloudModel(identifier: itemIdentifier.identifier)
            }
        })

        let defaultModel = ModelManager.ModelIdentifier.defaultModelForConversation
        let isDefaultModel = itemIdentifier.identifier == defaultModel
        actions.append(UIAction(
            title: isDefaultModel ? String(localized: "New Chat") : String(localized: "New Chat (Use Once)"),
            image: UIImage(systemName: "plus.bubble"),
        ) { [weak self] _ in
            let modelId = itemIdentifier.identifier
            let conversation = ConversationManager.shared.createNewConversation { conv in
                conv.update(\.modelId, to: modelId)
            }
            ChatSelection.shared.select(conversation.id, options: [.collapseSidebar, .focusEditor])
            self?.navigationController?.dismiss(animated: true)
        })

        return actions
    }

    func createModelMenu(for itemIdentifier: ModelViewModel) -> UIMenu {
        UIMenu(children: createModelMenuElements(for: itemIdentifier))
    }
}
