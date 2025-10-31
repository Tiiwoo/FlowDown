//
//  Sidebar.swift
//  FlowDown
//
//  Created by 秋星桥 on 1/21/25.
//

import Combine
import Storage
import UIKit

class Sidebar: UIView {
    let brandingLabel = SidebarBrandingLabel()
    let newChatButton = NewChatButton()
    let searchButton = SearchControllerOpenButton()
    let settingButton = SettingButton()
    let conversationListView = ConversationListView()
    let syncIndicator = SidebarSyncLabel()

    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(frame: .zero)

        setupChatSelectionSubscription()

        let spacing: CGFloat = 16

        addSubview(brandingLabel)
        addSubview(newChatButton)
        addSubview(settingButton)
        addSubview(searchButton)
        addSubview(syncIndicator)

        brandingLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.right.equalTo(newChatButton).offset(-spacing)
        }

        newChatButton.delegate = self
        newChatButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.height.equalTo(32)
            make.centerY.equalTo(brandingLabel.snp.centerY)
        }

        settingButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.right.bottom.equalToSuperview()
        }

        searchButton.delegate = self

        addSubview(conversationListView)
        conversationListView.snp.makeConstraints { make in
            make.top.equalTo(brandingLabel.snp.bottom).offset(spacing)
            make.bottom.equalTo(settingButton.snp.top).offset(-spacing)
            make.left.right.equalToSuperview()
        }

        syncIndicator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(settingButton.snp.right).offset(8)
            make.right.equalTo(searchButton.snp.left).offset(-8)
            make.height.equalTo(32)
        }
    }

    private func setupChatSelectionSubscription() {
        ChatSelection.shared.selection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] conversationId in
                Logger.ui.debugFile("Sidebar received chat selection update: \(conversationId ?? "nil")")
                if let conversationId {
                    self?.conversationListView.select(identifier: conversationId)
                }
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
