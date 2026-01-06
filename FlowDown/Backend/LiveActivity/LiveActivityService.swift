//
//  LiveActivityService.swift
//  FlowDown
//
//  Created by AI on 1/6/26.
//

import Foundation

#if canImport(ActivityKit) && os(iOS) && !targetEnvironment(macCatalyst)
    import ActivityKit

    @MainActor
    @available(iOS 16.2, *)
    final class LiveActivityService {
        static let shared = LiveActivityService()

        private var currentActivity: Activity<FlowDownWidgetsAttributes>?
        private var autoDismissWhenCompleted: Bool = true

        private init() {
            currentActivity = Activity<FlowDownWidgetsAttributes>.activities.first
        }

        func appWillEnterBackground() {
            autoDismissWhenCompleted = false
        }

        func appDidEnterForeground() {
            autoDismissWhenCompleted = true
            if ConversationSessionManager.shared.executingSessionsPublisher.value.isEmpty {
                endIfNeeded()
            }
        }

        func update(conversationCount: Int, streamingSessionTextCount: Int, enabled: Bool) {
            guard enabled else {
                endIfNeeded()
                return
            }

            if autoDismissWhenCompleted, conversationCount <= 0 {
                endIfNeeded()
                return
            }

            let state = FlowDownWidgetsAttributes.ContentState(
                runningSession: conversationCount,
                incomingTokens: streamingSessionTextCount,
                conversationCount: conversationCount,
                streamingSessionTextCount: streamingSessionTextCount,
            )

            if let activity = currentActivity {
                Task {
                    await activity.update(
                        ActivityContent(state: state, staleDate: nil),
                    )
                }
            } else {
                do {
                    let attributes = FlowDownWidgetsAttributes()
                    currentActivity = try Activity.request(
                        attributes: attributes,
                        content: ActivityContent(state: state, staleDate: nil),
                        pushType: nil,
                    )
                } catch {
                    logger.error("unable to start live activity \(error.localizedDescription)")
                }
            }
        }

        func endIfNeeded() {
            guard let activity = currentActivity else { return }
            currentActivity = nil
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

#endif
