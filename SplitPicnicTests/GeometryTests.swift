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
                    attempts: 1,
                    hintsUsed: 0
                )
                if !outcome.success {
                    failures.append(
                        "\(level.id) dog=\(outcome.dogHappy) cat=\(outcome.catHappy) area=\(outcome.areaOK) dogCounts=\(outcome.dogCounts) catCounts=\(outcome.catCounts)"
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

    @Test("Catalog has eight levels in every world")
    func eightEach() {
        for world in WorldID.allCases {
            #expect(LevelCatalog.levels(for: world).count == 8)
        }
        #expect(LevelCatalog.next(after: PlayContext(world: .sunsetBakery, levelIndex: 7, seed: 1, isDaily: false, theme: .pizzaParty, plate: .paw)) == nil)
        #expect(LevelCatalog.next(after: PlayContext(world: .pizzaPark, levelIndex: 7, seed: 1, isDaily: false, theme: .pizzaParty, plate: .paw))?.0 == .berryMeadow)
    }
}

private extension DailyStamp {
    static func date(year: Int, month: Int, day: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }
}
