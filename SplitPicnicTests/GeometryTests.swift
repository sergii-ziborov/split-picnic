import Foundation
import Testing
@testable import SplitPicnic

struct GeometryTests {
    @Test("Vertical cut through the center splits the disk in half")
    func verticalHalfArea() {
        let cut = Cut.vertical
        let ratios = cut.areaRatios
        #expect(abs(ratios.positive - 0.5) < 1e-9)
        #expect(abs(ratios.negative - 0.5) < 1e-9)
    }

    @Test("A cut that barely kisses the right edge has almost no positive area")
    func edgeCutArea() {
        let cut = Cut(angle: 0, offset: 0.999)
        #expect(cut.positiveArea < 0.05)
        #expect(cut.negativeArea > 3.0)
    }

    @Test("Points to the left of a vertical cut belong to the dog")
    func dogGetsTheLeft() {
        let cut = Cut.vertical
        #expect(SliceGeometry.dogHalf(for: cut) == .negative)
        #expect(cut.half(of: Vec2(x: -0.4, y: 0.1)) == .negative)
        #expect(cut.half(of: Vec2(x: 0.4, y: -0.1)) == .positive)
    }

    @Test("A line through two points reconstructs angle and offset")
    func throughPoints() {
        let cut = Cut.through(Vec2(x: 0, y: -1), Vec2(x: 0, y: 1))
        #expect(cut != nil)
        #expect(abs(cut!.offset) < 1e-9)
        #expect(abs(abs(cut!.normal.x) - 1) < 1e-9)
    }

    @Test("Chord exists only while the line hits the circle")
    func chordHit() {
        #expect(Cut.vertical.chord() != nil)
        #expect(Cut(angle: 0, offset: 1.2).chord() == nil)
    }

    @Test("A deliberate vertical swipe becomes a vertical cut")
    func swipeCreatesCut() {
        let center = CGPoint(x: 100, y: 100)
        let cut = SwipeGeometry.cut(
            from: CGPoint(x: 100, y: 30),
            to: CGPoint(x: 100, y: 170),
            center: center,
            radius: 80
        )
        #expect(cut != nil)
        #expect(abs(cut!.offset) < 1e-9)
        #expect(abs(abs(cut!.normal.x) - 1) < 1e-9)
    }

    @Test("Taps and swipes that miss the dish do not slice")
    func invalidSwipesAreIgnored() {
        let center = CGPoint(x: 100, y: 100)
        #expect(SwipeGeometry.cut(
            from: CGPoint(x: 98, y: 98),
            to: CGPoint(x: 104, y: 104),
            center: center,
            radius: 80
        ) == nil)
        #expect(SwipeGeometry.cut(
            from: CGPoint(x: 10, y: 10),
            to: CGPoint(x: 10, y: 190),
            center: center,
            radius: 80
        ) == nil)
    }

    @Test("A curved swipe keeps its bends and routes toppings around them")
    func curvedSwipeCreatesFreeformCut() {
        let center = CGPoint(x: 100, y: 100)
        let cut = SwipeGeometry.cut(
            from: [
                CGPoint(x: 100, y: 15),
                CGPoint(x: 108, y: 55),
                CGPoint(x: 136, y: 100),
                CGPoint(x: 108, y: 145),
                CGPoint(x: 100, y: 185),
            ],
            center: center,
            radius: 80
        )

        #expect(cut != nil)
        #expect(cut?.isFreeform == true)
        #expect((cut?.pathPoints.count ?? 0) >= 5)
        // The curve bows right: this point is right of the end-to-end chord but
        // still on the left-hand piece created by the actual finger trail.
        #expect(cut?.half(of: Vec2(x: 0.20, y: 0)) == .negative)
        #expect(cut?.half(of: Vec2(x: 0.70, y: 0)) == .positive)
        let ratios = cut?.areaRatios
        #expect(abs((ratios?.positive ?? 0) + (ratios?.negative ?? 0) - 1) < 1e-9)
    }

    @Test("A looping swipe is rejected instead of making ambiguous pieces")
    func selfIntersectingSwipeIsIgnored() {
        let center = CGPoint(x: 100, y: 100)
        let cut = SwipeGeometry.cut(
            from: [
                CGPoint(x: 100, y: 15),
                CGPoint(x: 135, y: 75),
                CGPoint(x: 70, y: 125),
                CGPoint(x: 135, y: 125),
                CGPoint(x: 70, y: 75),
                CGPoint(x: 100, y: 185),
            ],
            center: center,
            radius: 80
        )
        #expect(cut == nil)
    }
}

struct EvaluatorTests {
    @Test("Exclusive pepperoni order rejects mushrooms")
    func exclusiveRejects() {
        let counts: [ToppingKind: Int] = [.pepperoni: 3, .mushroom: 1]
        #expect(!SliceEvaluator.matches(.exclusive([.pepperoni]), counts: counts))
        #expect(SliceEvaluator.matches(.exclusive([.pepperoni]), counts: [.pepperoni: 3]))
    }

    @Test("Remainder is happy with anything non-empty")
    func remainderHappy() {
        #expect(SliceEvaluator.matches(.remainder, counts: [.olive: 2]))
        #expect(!SliceEvaluator.matches(.remainder, counts: [:]))
    }

    @Test("Exact strawberry count with a cherry forbid")
    func berryRules() {
        let order = GuestOrder.exact(.strawberry, count: 2, forbidden: [.cherry], allowOthers: true)
        #expect(SliceEvaluator.matches(order, counts: [.strawberry: 2, .blueberry: 1]))
        #expect(!SliceEvaluator.matches(order, counts: [.strawberry: 2, .cherry: 1]))
        #expect(!SliceEvaluator.matches(order, counts: [.strawberry: 1, .blueberry: 1]))
    }

    @Test("Fair-slice rule rejects a greedy cut")
    func fairSlice() {
        #expect(SliceEvaluator.areaOK(cut: .vertical, minRatio: 0.4))
        #expect(!SliceEvaluator.areaOK(cut: Cut(angle: 0, offset: 0.5), minRatio: 0.4))
        #expect(SliceEvaluator.areaOK(cut: Cut(angle: 0, offset: 0.5), minRatio: nil))
    }

    @Test("Clean-slice rule detects contact with topping artwork")
    func cleanSlice() {
        let topping = Topping(
            id: 0,
            kind: .pepperoni,
            position: Vec2(x: 0.05, y: 0.2),
            radius: 0.085
        )
        #expect(!SliceEvaluator.isClean(toppings: [topping], cut: .vertical, required: true))
        #expect(SliceEvaluator.isClean(
            toppings: [topping],
            cut: Cut(angle: 0, offset: 0.35),
            required: true
        ))
        #expect(SliceEvaluator.isClean(toppings: [topping], cut: .vertical, required: false))
    }

    @Test("Stars reward a clean first slice")
    func starPolicy() {
        #expect(StarRating.stars(attempts: 1, hintsUsed: 0) == 3)
        #expect(StarRating.stars(attempts: 1, hintsUsed: 1) == 2)
        #expect(StarRating.stars(attempts: 2, hintsUsed: 0) == 2)
        #expect(StarRating.stars(attempts: 3, hintsUsed: 2) == 1)
    }
}

struct CatalogTests {
    @Test("Every authored hint cut actually feeds both guests")
    func hintCutsSolve() {
        var failures: [String] = []
        for world in WorldID.allCases {
            for level in LevelCatalog.levels(for: world) {
                let toppings = DishLayout.build(level: level, seed: 77)
                let expected = level.leftKinds.count + level.rightKinds.count
                if toppings.count != expected {
                    failures.append("\(level.id) placed \(toppings.count)/\(expected)")
                    continue
                }
                let outcome = SliceEvaluator.evaluate(
                    toppings: toppings,
                    cut: level.hint,
                    dog: level.dog,
                    cat: level.cat,
                    minAreaRatio: level.minAreaRatio,
                    requiresCleanCut: level.requiresCleanCut,
                    attempts: 1,
                    hintsUsed: 0
                )
                if !outcome.success {
                    failures.append(
                        "\(level.id) dog=\(outcome.dogHappy) cat=\(outcome.catHappy) area=\(outcome.areaOK) clean=\(outcome.cleanCut) dogCounts=\(outcome.dogCounts) catCounts=\(outcome.catCounts)"
                    )
                }
            }
        }
        if !failures.isEmpty {
            Issue.record("Unsolved hint cuts: \(failures.joined(separator: " | "))")
        }
        #expect(failures.isEmpty)
    }

    @Test("A horizontal cut fails the opening pepperoni/mushroom split")
    func wrongCutFails() {
        let level = LevelCatalog.level(world: .pizzaPark, index: 0)
        let toppings = DishLayout.build(level: level, seed: 11)
        let wrong = Cut(angle: .pi / 2, offset: 0)
        let outcome = SliceEvaluator.evaluate(
            toppings: toppings,
            cut: wrong,
            dog: level.dog,
            cat: level.cat,
            minAreaRatio: level.minAreaRatio,
            requiresCleanCut: level.requiresCleanCut,
            attempts: 1,
            hintsUsed: 0
        )
        #expect(!outcome.success)
    }

    @Test("The same seed lays out the same toppings")
    func seedStable() {
        let level = LevelCatalog.level(world: .berryMeadow, index: 0)
        let a = DishLayout.build(level: level, seed: 1_001)
        let b = DishLayout.build(level: level, seed: 1_001)
        #expect(a.map(\.kind) == b.map(\.kind))
        #expect(a.map(\.position) == b.map(\.position))
    }

    @Test("World unlock gates stay in order")
    func unlockOrder() {
        #expect(WorldID.pizzaPark.starsToUnlock == 0)
        #expect(WorldID.berryMeadow.starsToUnlock > 0)
        #expect(WorldID.forestPicnic.starsToUnlock > WorldID.berryMeadow.starsToUnlock)
        #expect(WorldID.sunsetBakery.starsToUnlock > WorldID.forestPicnic.starsToUnlock)
    }

    @Test("Daily pick is stable for a UTC day")
    func dailyStable() {
        let date = DailyStamp.date(year: 2026, month: 9, day: 9)!
        let a = LevelCatalog.daily(on: date, unlocked: WorldID.allCases)
        let b = LevelCatalog.daily(on: date, unlocked: WorldID.allCases)
        #expect(a.0 == b.0 && a.1 == b.1 && a.2 == b.2)
    }

    @Test("Catalog has twelve levels in every world")
    func twelveEach() {
        for world in WorldID.allCases {
            #expect(LevelCatalog.levels(for: world).count == 12)
        }
        #expect(LevelCatalog.next(after: PlayContext(world: .sunsetBakery, levelIndex: 11, seed: 1, isDaily: false, theme: .pizzaParty, plate: .paw)) == nil)
        #expect(LevelCatalog.next(after: PlayContext(world: .pizzaPark, levelIndex: 11, seed: 1, isDaily: false, theme: .pizzaParty, plate: .paw))?.0 == .berryMeadow)
    }

    @Test("Picnics rotate through mixed guest casts")
    func guestCastVariety() {
        var casts: Set<String> = []
        for world in WorldID.allCases {
            for levelIndex in 0..<12 {
                let context = PlayContext(
                    world: world,
                    levelIndex: levelIndex,
                    seed: 1,
                    isDaily: false,
                    theme: .pizzaParty,
                    plate: .paw
                )
                let dog = context.guestVariant(for: .dog)
                let cat = context.guestVariant(for: .cat)
                casts.insert("\(dog.rawValue)-\(cat.rawValue)")
            }
        }

        #expect(casts.count == 7)
        #expect(casts.contains("woodland-woodland"))
        #expect(casts.contains("classic-woodland"))
        #expect(casts.contains("sunny-classic"))
    }

    @Test("Unlocked picnic themes rotate through the level journey")
    func themeRotation() {
        var progress = ProgressState.fresh
        #expect(progress.theme(for: .pizzaPark, levelIndex: 9) == .pizzaParty)

        for level in LevelCatalog.levels(for: .pizzaPark).prefix(8) {
            progress.starsByLevel[level.id] = 3
        }
        let themes = (0..<12).map { progress.theme(for: .pizzaPark, levelIndex: $0) }
        #expect(Set(themes.map(\.rawValue)).count >= 3)
        #expect(themes[0] != themes[3])
        #expect(themes.allSatisfy { progress.isThemeUnlocked($0) })

        progress.selectedTheme = .berryPicnic
        #expect(progress.theme(for: .pizzaPark, levelIndex: 0) == .berryPicnic)
    }

    @Test("Pizza bases alternate without changing on retry")
    func pizzaAppearanceVariety() {
        let first = PlayContext(world: .pizzaPark, levelIndex: 0, seed: 1, isDaily: false, theme: .pizzaParty, plate: .paw)
        let second = PlayContext(world: .pizzaPark, levelIndex: 2, seed: 2, isDaily: false, theme: .pizzaParty, plate: .paw)
        #expect(first.pizzaBaseAsset != second.pizzaBaseAsset)
        #expect(first.pizzaBaseAsset == PlayContext(world: .pizzaPark, levelIndex: 0, seed: 999, isDaily: false, theme: .pizzaParty, plate: .paw).pizzaBaseAsset)
    }
}

private extension DailyStamp {
    static func date(year: Int, month: Int, day: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }
}
