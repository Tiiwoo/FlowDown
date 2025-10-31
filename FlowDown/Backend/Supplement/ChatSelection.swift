//
//  ChatSelection.swift
//  FlowDown
//
//  Created by 秋星桥 on 2025/10/31.
//

import Combine
import Foundation
import Storage

class ChatSelection {
    static let shared = ChatSelection()

    private let subject = CurrentValueSubject<Conversation.ID?, Never>(nil)
    let selection: AnyPublisher<Conversation.ID?, Never>

    private init() {
        selection = subject
            .ensureMainThread()
            .eraseToAnyPublisher()
        subject.send(sdb.conversationList().first?.id)
    }

    func select(_ conversationId: Conversation.ID?) {
        Logger.ui.debugFile("ChatSelection.select called with: \(conversationId ?? "nil")")
        subject.send(conversationId)
    }
}
