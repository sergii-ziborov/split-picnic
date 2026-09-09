import Foundation

enum LevelCatalog {
    static func levels(for world: WorldID) -> [LevelDef] {
        switch world {
        case .pizzaPark: pizzaPark
        case .berryMeadow: berryMeadow
        case .forestPicnic: forestPicnic
        case .sunsetBakery: sunsetBakery
        }
    }

    static func level(world: WorldID, index: Int) -> LevelDef {
        let list = levels(for: world)
        return list[min(max(0, index), list.count - 1)]
    }

    static func next(after context: PlayContext) -> (WorldID, Int)? {
        let list = levels(for: context.world)
        let nextIndex = context.levelIndex + 1
        if nextIndex < list.count {
            return (context.world, nextIndex)
        }
        if let worldIndex = WorldID.allCases.firstIndex(of: context.world),
           worldIndex + 1 < WorldID.allCases.count
        {
            return (WorldID.allCases[worldIndex + 1], 0)
        }
        return nil
    }

    static func daily(on date: Date = Date(), unlocked: [WorldID]) -> (WorldID, Int, UInt64) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 1
        let seed = UInt64(day) &* 1_000_003 &+ 41
        var rng = SeededRNG(seed: seed)
        let worlds = unlocked.isEmpty ? [WorldID.pizzaPark] : unlocked
        let world = worlds[rng.nextInt(in: 0...(worlds.count - 1))]
        let count = max(levels(for: world).count, 1)
        let index = rng.nextInt(in: 0...(count - 1))
        return (world, index, seed)
    }

    private static func make(
        _ world: WorldID,
        _ index: Int,
        number: Int,
        _ name: String,
        _ blurb: String,
        dish: DishKind? = nil,
        hint: Cut,
        left: [ToppingKind],
        right: [ToppingKind],
        dog: GuestOrder,
        cat: GuestOrder,
        minArea: Double? = nil,
        hints: Int = 2,
        margin: Double = 0.16
    ) -> LevelDef {
        LevelDef(
            world: world,
            index: index,
            number: number,
            name: name,
            blurb: blurb,
            dish: dish ?? world.dish,
            hint: hint,
            leftKinds: left,
            rightKinds: right,
            dog: dog,
            cat: cat,
            minAreaRatio: minArea,
            hints: hints,
            margin: margin
        )
    }

    private static let pep = ToppingKind.pepperoni
    private static let mush = ToppingKind.mushroom
    private static let olive = ToppingKind.olive
    private static let pepper = ToppingKind.pepper
    private static let basil = ToppingKind.basil
    private static let straw = ToppingKind.strawberry
    private static let blue = ToppingKind.blueberry
    private static let cherry = ToppingKind.cherry

    private static let pizzaPark: [LevelDef] = [
        make(.pizzaPark, 0, number: 1, "First slice", "Pepperoni for the pup. Mushrooms for the kitten.",
             hint: Cut(angle: 0, offset: 0),
             left: [pep, pep, pep, pep],
             right: [mush, mush, mush, mush],
             dog: .exclusive([.pepperoni]),
             cat: .exclusive([.mushroom]),
             hints: 3, margin: 0.22),
        make(.pizzaPark, 1, number: 2, "Olives please", "Same idea. New topping.",
             hint: Cut(angle: 0.12, offset: 0),
             left: [pep, pep, pep, pep],
             right: [olive, olive, olive, olive],
             dog: .exclusive([.pepperoni]),
             cat: .exclusive([.olive]),
             hints: 3, margin: 0.20),
        make(.pizzaPark, 2, number: 3, "A little tilt", "The honest cut is no longer vertical.",
             hint: Cut(angle: 0.40, offset: 0),
             left: [pep, pep, pep, basil],
             right: [pepper, pepper, pepper],
             dog: .exclusive([.pepperoni, .basil], minEach: 1),
             cat: .exclusive([.pepper]),
             hints: 3, margin: 0.18),
        make(.pizzaPark, 3, number: 4, "You get the rest", "The pup wants pepperoni. The kitten is easy.",
             hint: Cut(angle: -0.28, offset: 0.05),
             left: [pep, pep, pep],
             right: [mush, olive, olive, basil],
             dog: .exclusive([.pepperoni]),
             cat: .remainder,
             hints: 2, margin: 0.18),
        make(.pizzaPark, 4, number: 5, "Off center", "The line does not have to go through the middle.",
             hint: Cut(angle: 0, offset: -0.22),
             left: [pep, pep, pep, pep],
             right: [mush, mush, olive, olive, basil],
             dog: .exact(.pepperoni, count: 4, allowOthers: false),
             cat: .remainder,
             hints: 2, margin: 0.16),
        make(.pizzaPark, 5, number: 6, "No olives", "Pepperoni only. Olives stay off the pup's plate.",
             hint: Cut(angle: 0.55, offset: 0.08),
             left: [pep, pep, pep, basil],
             right: [olive, olive, olive, mush],
             dog: .exclusive([.pepperoni, .basil], minEach: 1),
             cat: .remainder,
             hints: 2, margin: 0.16),
        make(.pizzaPark, 6, number: 7, "Two toppings", "Pepperoni and peppers on the left.",
             hint: Cut(angle: -0.48, offset: 0),
             left: [pep, pep, pepper, pepper],
             right: [mush, mush, mush, olive],
             dog: .exclusive([.pepperoni, .pepper]),
             cat: .exclusive([.mushroom, .olive], minEach: 1),
             hints: 2, margin: 0.15),
        make(.pizzaPark, 7, number: 8, "Park exam", "A tighter corridor. Still one honest line.",
             hint: Cut(angle: 0.72, offset: -0.10),
             left: [pep, pep, pep, pepper],
             right: [mush, mush, olive, olive, basil],
             dog: .exclusive([.pepperoni, .pepper]),
             cat: .remainder,
             hints: 1, margin: 0.13),
    ]

    private static let berryMeadow: [LevelDef] = [
        make(.berryMeadow, 0, number: 9, "Two strawberries", "The pup wants two strawberries and no cherries.",
             hint: Cut(angle: 0, offset: 0.12),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry], allowOthers: true),
             cat: .remainder,
             hints: 3, margin: 0.20),
        make(.berryMeadow, 1, number: 10, "Leave the cherries", "Same rule, busier tart.",
             hint: Cut(angle: 0.22, offset: 0),
             left: [straw, straw, straw],
             right: [cherry, cherry, blue, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 3)], forbidden: [.cherry]),
             cat: .remainder,
             hints: 2, margin: 0.18),
        make(.berryMeadow, 2, number: 11, "Blue for kitty", "The kitten wants blueberries only.",
             hint: Cut(angle: -0.35, offset: -0.08),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.blueberry], allowOthers: true),
             cat: .exclusive([.blueberry]),
             hints: 2, margin: 0.16),
        make(.berryMeadow, 3, number: 12, "Three cherries", "Count carefully. The rest can wander.",
             hint: Cut(angle: 0.60, offset: 0.14),
             left: [cherry, cherry, cherry],
             right: [straw, straw, blue, blue],
             dog: .exact(.cherry, count: 3, allowOthers: false),
             cat: .remainder,
             hints: 2, margin: 0.16),
        make(.berryMeadow, 4, number: 13, "Diagonal tart", "The honest line leans.",
             hint: Cut(angle: 0.90, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             hints: 2, margin: 0.15),
        make(.berryMeadow, 5, number: 14, "Offset berries", "More fruit on one side is allowed.",
             hint: Cut(angle: 0, offset: 0.28),
             left: [straw, straw],
             right: [cherry, cherry, cherry, blue, blue, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry], allowOthers: false),
             cat: .remainder,
             hints: 2, margin: 0.15),
        make(.berryMeadow, 6, number: 15, "Mixed bowl", "Strawberries left, cherries right, blues split by the line.",
             hint: Cut(angle: -0.70, offset: -0.06),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 3)], forbidden: [.strawberry]),
             hints: 1, margin: 0.14),
        make(.berryMeadow, 7, number: 16, "Meadow exam", "Two strawberries. Zero cherries. Tighter.",
             hint: Cut(angle: 1.05, offset: 0.10),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             hints: 1, margin: 0.12),
    ]

    private static let forestPicnic: [LevelDef] = [
        make(.forestPicnic, 0, number: 17, "Both want", "Pepperoni left. Mushrooms right. Both guests are picky.",
             hint: Cut(angle: 0.18, offset: 0),
             left: [pep, pep, pep, basil],
             right: [mush, mush, mush, olive],
             dog: .exclusive([.pepperoni, .basil]),
             cat: .exclusive([.mushroom, .olive]),
             hints: 2, margin: 0.16),
        make(.forestPicnic, 1, number: 18, "Peppers and olives", "A forest mix with a clean seam.",
             hint: Cut(angle: -0.42, offset: 0.10),
             left: [pepper, pepper, pep],
             right: [olive, olive, olive, mush],
             dog: .exclusive([.pepper, .pepperoni]),
             cat: .exclusive([.olive, .mushroom]),
             hints: 2, margin: 0.15),
        make(.forestPicnic, 2, number: 19, "Tight path", "The toppings sit closer to the line.",
             hint: Cut(angle: 0.80, offset: -0.12),
             left: [pep, pep, olive],
             right: [mush, mush, pepper, basil],
             dog: .exclusive([.pepperoni, .olive]),
             cat: .exclusive([.mushroom, .pepper, .basil], minEach: 1),
             hints: 2, margin: 0.13),
        make(.forestPicnic, 3, number: 20, "Three rules", "Counts, not just kinds.",
             hint: Cut(angle: 0.30, offset: 0.18),
             left: [pep, pep, pep],
             right: [mush, mush, olive, olive, basil],
             dog: .exact(.pepperoni, count: 3, allowOthers: false),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 2, max: 2), CountRule(kind: .olive, min: 2, max: 2)],
                allowOthers: true
             ),
             hints: 2, margin: 0.14),
        make(.forestPicnic, 4, number: 21, "Lay it flat", "A nearly horizontal cut is the honest one.",
             hint: Cut(angle: 1.40, offset: 0),
             left: [pep, pep, pepper, pepper],
             right: [mush, mush, olive, basil],
             dog: .exclusive([.pepperoni, .pepper]),
             cat: .exclusive([.mushroom, .olive, .basil], minEach: 1),
             hints: 1, margin: 0.14),
        make(.forestPicnic, 5, number: 22, "Forest mix", "More toppings. Same one-line rule.",
             hint: Cut(angle: -0.85, offset: 0.08),
             left: [pep, pep, basil, basil],
             right: [mush, olive, olive, pepper, pepper],
             dog: .exclusive([.pepperoni, .basil]),
             cat: .remainder,
             hints: 1, margin: 0.13),
        make(.forestPicnic, 6, number: 23, "Narrow lane", "Leave a corridor and slide the line into it.",
             hint: Cut(angle: 0.50, offset: -0.16),
             left: [pep, pep, pep, olive],
             right: [mush, mush, pepper, basil, olive],
             dog: .counts([CountRule(kind: .pepperoni, min: 3, max: 3)], forbidden: [.mushroom, .pepper], allowOthers: true),
             cat: .remainder,
             hints: 1, margin: 0.12),
        make(.forestPicnic, 7, number: 24, "Forest exam", "Both orders, a lean, a little offset.",
             hint: Cut(angle: 1.10, offset: 0.12),
             left: [pep, pepper, pepper, basil],
             right: [mush, mush, olive, olive],
             dog: .exclusive([.pepperoni, .pepper, .basil], minEach: 1),
             cat: .exclusive([.mushroom, .olive]),
             hints: 1, margin: 0.12),
    ]

    private static let sunsetBakery: [LevelDef] = [
        make(.sunsetBakery, 0, number: 25, "Fair half", "The pup wants two strawberries. Keep the slices close in size.",
             hint: Cut(angle: 0, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.36,
             hints: 2, margin: 0.16),
        make(.sunsetBakery, 1, number: 26, "Fair tart", "Same berries, a little tilt still counts as fair.",
             hint: Cut(angle: 0.32, offset: 0),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, cherry],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.blueberry]),
             cat: .remainder,
             minArea: 0.36,
             hints: 2, margin: 0.15),
        make(.sunsetBakery, 2, number: 27, "Forty percent", "Neither guest leaves hungry.",
             hint: Cut(angle: -0.25, offset: 0.06),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.40,
             hints: 2, margin: 0.14),
        make(.sunsetBakery, 3, number: 28, "Counts and fairness", "Orders plus a fair split.",
             hint: Cut(angle: 0.55, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 2)], forbidden: [.strawberry]),
             minArea: 0.38,
             hints: 1, margin: 0.14),
        make(.sunsetBakery, 4, number: 29, "Diagonal fair", "Lean the knife. Keep the areas honest.",
             hint: Cut(angle: 0.95, offset: 0),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, cherry],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], allowOthers: true),
             cat: .remainder,
             minArea: 0.40,
             hints: 1, margin: 0.13),
        make(.sunsetBakery, 5, number: 30, "Offset fair", "A slight shift is fine. A greedy slice is not.",
             hint: Cut(angle: 0.15, offset: 0.12),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.38,
             hints: 1, margin: 0.13),
        make(.sunsetBakery, 6, number: 31, "Busy pie", "More fruit, still one line, still fair.",
             hint: Cut(angle: -0.60, offset: 0),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.40,
             hints: 1, margin: 0.12),
        make(.sunsetBakery, 7, number: 32, "Bakery exam", "Both orders, fair slices, a leaning cut.",
             hint: Cut(angle: 1.15, offset: 0.05),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 2)], forbidden: [.strawberry]),
             minArea: 0.42,
             hints: 1, margin: 0.12),
    ]
}
