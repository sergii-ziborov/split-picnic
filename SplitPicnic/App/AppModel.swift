import Foundation
import SwiftUI

enum Screen: Equatable {
    case home
    case tutorial
    case play
    case result
    case fail
    case worlds
    case collection
    case daily
    case settings
}

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var session: PlaySession?
    var lastOutcome: RoundOutcome?
    var tutorialReturnScreen: Screen?

    private let store: ProgressStore

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        let arguments = ProcessInfo.processInfo.arguments
        var loaded = store.load()
        if arguments.contains("reset-progress") {
            loaded = .fresh
        }
        if arguments.contains("ui-testing") {
            loaded.tutorialSeen = true
        }
        if arguments.contains("ui-progress-map") {
            for level in LevelCatalog.levels(for: .pizzaPark) {
                loaded.starsByLevel[level.id] = 3
            }
            for level in LevelCatalog.levels(for: .berryMeadow).prefix(7) {
                loaded.starsByLevel[level.id] = 2
            }
            for level in LevelCatalog.levels(for: .forestPicnic).prefix(3) {
                loaded.starsByLevel[level.id] = 1
            }
            loaded.totalSolves = loaded.starsByLevel.count
        }
        self.progress = loaded

        let previewPrefix = "ui-level="
        if arguments.contains("ui-testing"),
           let value = arguments.first(where: { $0.hasPrefix(previewPrefix) }),
           let number = Int(value.dropFirst(previewPrefix.count)),
           let level = WorldID.allCases
               .flatMap({ LevelCatalog.levels(for: $0) })
               .first(where: { $0.number == number })
        {
            let context = PlayContext(
                world: level.world,
                levelIndex: level.index,
                seed: 77,
                isDaily: false,
                theme: loaded.theme(for: level.world, levelIndex: level.index),
                plate: loaded.selectedPlate
            )
            let session = PlaySession(context: context)
            if arguments.contains("ui-curved-preview"),
               let cut = Cut.following([
                   Vec2(x: -0.05, y: 1),
                   Vec2(x: 0.18, y: 0.55),
                   Vec2(x: 0.38, y: 0.05),
                   Vec2(x: 0.20, y: -0.48),
                   Vec2(x: -0.04, y: -1),
               ])
            {
                session.draft = cut
                session.attempts = 1
                session.lastSlice = session.evaluate(cut: cut)
                session.phase = .resolved
            }
            self.session = session
            self.screen = .play
        }
        if !loaded.tutorialSeen && !arguments.contains("ui-testing") && screen == .home {
            screen = .tutorial
        }
    }

    var uiTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    var loc: L10n { L10n(language: progress.language) }

    func playTapped() {
        if !progress.tutorialSeen {
            tutorialReturnScreen = nil
            screen = .tutorial
            return
        }
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func finishTutorial() {
        tutorialReturnScreen = nil
        progress.tutorialSeen = true
        saveProgress()
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func openTutorial(from source: Screen) {
        tutorialReturnScreen = source
        screen = .tutorial
    }

    func closeTutorial() {
        if let source = tutorialReturnScreen {
            tutorialReturnScreen = nil
            screen = source
        } else {
            goHome()
        }
    }

    func playDaily() {
        let unlocked = WorldID.allCases.filter { progress.isUnlocked($0) }
        let pick = LevelCatalog.daily(unlocked: unlocked)
        startPlay(world: pick.0, index: pick.1, daily: true, seed: pick.2)
    }

    func play(world: WorldID, index: Int) {
        guard progress.isUnlocked(world) else { return }
        startPlay(world: world, index: index, daily: false)
    }

    func retry() {
        guard let session else { return }
        startPlay(
            world: session.context.world,
            index: session.context.levelIndex,
            daily: session.context.isDaily,
            seed: session.context.isDaily ? session.context.seed : session.context.seed
        )
    }

    func nextLevel() {
        guard let session else {
            screen = .home
            return
        }
        if session.context.isDaily {
            goHome()
            return
        }
        if let next = LevelCatalog.next(after: session.context), progress.isUnlocked(next.0) {
            startPlay(world: next.0, index: next.1, daily: false)
        } else {
            screen = .worlds
            self.session = nil
        }
    }

    func confirmSlice() {
        guard let session, session.phase == .aiming, let cut = session.draft else { return }
        session.attempts += 1
        let outcome = session.evaluate(cut: cut)
        session.lastSlice = outcome
        session.phase = progress.reduceMotion ? .resolved : .slicing
        Feedback.slice(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
        if progress.reduceMotion {
            finishSlice()
        }
    }

    func slice(with cut: Cut) {
        guard let session, session.phase == .aiming else { return }
        session.draft = cut
        session.showHint = false
        confirmSlice()
    }

    func finishSlice() {
        guard let session, let slice = session.lastSlice else { return }
        session.phase = .resolved
        if slice.success {
            progress.record(level: session.context.level, stars: slice.stars, daily: session.context.isDaily)
            store.save(progress)
            lastOutcome = RoundOutcome(
                stars: slice.stars,
                attempts: session.attempts,
                hintsUsed: session.hintsUsed,
                world: session.context.world,
                levelIndex: session.context.levelIndex,
                isDaily: session.context.isDaily,
                dogHappy: true,
                catHappy: true,
                areaOK: true,
                cleanCut: true
            )
            Feedback.success(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
            screen = .result
        } else {
            lastOutcome = RoundOutcome(
                stars: 0,
                attempts: session.attempts,
                hintsUsed: session.hintsUsed,
                world: session.context.world,
                levelIndex: session.context.levelIndex,
                isDaily: session.context.isDaily,
                dogHappy: slice.dogHappy,
                catHappy: slice.catHappy,
                areaOK: slice.areaOK,
                cleanCut: slice.cleanCut
            )
            Feedback.miss(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
            screen = .fail
        }
    }

    func useHint() {
        guard let session, session.phase == .aiming, !session.showHint, session.hintsLeft > 0 else { return }
        session.showHint = true
        session.hintsUsed += 1
        session.hintsLeft -= 1
        Feedback.hint(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
    }

    func selectTheme(_ theme: ThemeID) {
        guard progress.isThemeUnlocked(theme) else { return }
        progress.selectedTheme = theme
        saveProgress()
        Feedback.tap(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
    }

    func selectPlate(_ plate: PlateID) {
        guard progress.isPlateUnlocked(plate) else { return }
        progress.selectedPlate = plate
        saveProgress()
        Feedback.tap(sound: progress.soundEnabled, haptics: progress.hapticsEnabled)
    }

    func saveProgress() {
        store.save(progress)
    }

    func resetProgress() {
        let language = progress.language
        progress = .fresh
        progress.language = language
        if uiTesting { progress.tutorialSeen = true }
        store.save(progress)
    }

    func goHome() {
        session = nil
        lastOutcome = nil
        screen = .home
    }

    private func startPlay(world: WorldID, index: Int, daily: Bool, seed: UInt64? = nil) {
        let context = PlayContext(
            world: world,
            levelIndex: index,
            seed: seed ?? UInt64.random(in: 1...UInt64.max),
            isDaily: daily,
            theme: progress.theme(for: world, levelIndex: index, isDaily: daily, seed: seed ?? 0),
            plate: progress.selectedPlate
        )
        let session = PlaySession(context: context)
        self.session = session
        lastOutcome = nil
        screen = .play
        Feedback.ready(sound: progress.soundEnabled)
    }
}

@MainActor
@Observable
final class PlaySession {
    let context: PlayContext
    let toppings: [Topping]
    var draft: Cut?
    var phase: Phase = .aiming
    var attempts: Int = 0
    var hintsUsed: Int = 0
    var hintsLeft: Int
    var showHint: Bool = false
    var lastSlice: SliceOutcome?

    enum Phase: Equatable {
        case aiming
        case slicing
        case resolved
    }

    var level: LevelDef { context.level }

    init(context: PlayContext) {
        self.context = context
        self.toppings = DishLayout.build(level: context.level, seed: context.seed)
        self.hintsLeft = context.level.hints
    }

    func evaluate(cut: Cut) -> SliceOutcome {
        SliceEvaluator.evaluate(
            toppings: toppings,
            cut: cut,
            dog: level.dog,
            cat: level.cat,
            minAreaRatio: level.minAreaRatio,
            requiresCleanCut: level.requiresCleanCut,
            attempts: attempts,
            hintsUsed: hintsUsed
        )
    }
}
