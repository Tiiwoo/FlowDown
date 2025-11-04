import AppIntents

struct FlowDownAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor { .lime }

    static var appShortcuts: [AppShortcut] = [
        AppShortcut(
            intent: GenerateChatResponseIntent(),
            phrases: [
                "Ask Model on \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Ask Model", defaultValue: "Ask Model"),
            systemImageName: "text.bubble"
        ),
    ]
}
