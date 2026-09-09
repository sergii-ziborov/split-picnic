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

    private let store: ProgressStore

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        var loaded = store.load()
        if ProcessInfo.processInfo.arguments.contains("ui-testing") {
            loaded.tutorialSeen = true
        }
        self.progress = loaded
    }

    var uiTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("ui-testing")
    }

    var loc: L10n { L10n(language: progress.language) }

    func playTapped() {
        if !progress.tutorialSeen {
            screen = .tutorial
            return
        }
        let next = progress.nextPlayable()
        startPlay(world: next.0, index: next.1, daily: false)
    }

    func finishTutorial() {
        progress.tutorialSeen = true
        saveProgress()
        startPlay(world: .pizzaPark, index: 0, daily: false)
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
        if progress.hapticsEnabled {
            Feedback.slice(sound: progress.soundEnabled)
        } else if progress.soundEnabled {
            Feedback.slice(sound: true)
        }
        if progress.reduceMotion {
            finishSlice()
        }
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
                areaOK: true
            )
            if progress.hapticsEnabled || progress.soundEnabled {
                Feedback.success(sound: progress.soundEnabled)
            }
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
                areaOK: slice.areaOK
            )
            if progress.hapticsEnabled || progress.soundEnabled {
                Feedback.miss(sound: progress.soundEnabled)
            }
            screen = .fail
        }
    }

    func useHint() {
        guard let session, session.hintsLeft > 0 else { return }
        session.showHint = true
        session.hintsUsed += 1
        session.hintsLeft -= 1
        if progress.hapticsEnabled { Feedback.hint() }
    }

    func selectTheme(_ theme: ThemeID) {
        guard progress.isThemeUnlocked(theme) else { return }
        progress.selectedTheme = theme
        saveProgress()
    }

    func selectPlate(_ plate: PlateID) {
        guard progress.isPlateUnlocked(plate) else { return }
        progress.selectedPlate = plate
        saveProgress()
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
            theme: progress.selectedTheme,
            plate: progress.selectedPlate
        )
        let session = PlaySession(context: context)
        if uiTesting {
            session.draft = session.level.hint
        }
        self.session = session
        lastOutcome = nil
        screen = .play
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
            attempts: attempts,
            hintsUsed: hintsUsed
        )
    }
}
