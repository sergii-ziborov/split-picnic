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
        ZStack {
            // Kept at the window root so the artwork also paints behind the status
            // bar and home indicator on a physical device.
            PicnicBackdrop(asset: backdrop.asset, dim: backdrop.dim)

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

    private var backdrop: (asset: String, dim: Double) {
        switch model.screen {
        case .worlds:
            return ("WorldsMap", 0.08)
        case .play:
            return (model.session?.context.world.backgroundAsset ?? "PicnicBackground", 0.12)
        case .result, .fail:
            return (model.lastOutcome?.world.backgroundAsset ?? "PicnicBackground", 0)
        case .collection:
            return ("PicnicBackground", 0.05)
        default:
            return ("PicnicBackground", 0)
        }
    }
}
