import SwiftUI

@main
struct SplitPicnicApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            switch model.screen {
            case .home:
                HomeView()
            case .tutorial:
                TutorialView()
            case .play:
                PlayView()
            case .result:
                ResultView()
            case .fail:
                FailView()
            case .worlds:
                WorldsView()
            case .collection:
                CollectionView()
            case .daily:
                DailyView()
            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .tint(Palette.moss)
        .preferredColorScheme(.light)
    }

    private var screenKey: String {
        switch model.screen {
        case .home: "home"
        case .tutorial: "tutorial"
        case .play: "play"
        case .result: "result"
        case .fail: "fail"
        case .worlds: "worlds"
        case .collection: "collection"
        case .daily: "daily"
        case .settings: "settings"
        }
    }
}
