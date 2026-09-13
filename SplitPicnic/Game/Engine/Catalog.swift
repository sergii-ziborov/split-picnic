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
        cleanCut: Bool = false,
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
            requiresCleanCut: cleanCut,
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
    private static let pineapple = ToppingKind.pineapple
    private static let onion = ToppingKind.onion
    private static let corn = ToppingKind.corn
    private static let mozzarella = ToppingKind.mozzarella

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
        make(.pizzaPark, 4, number: 5, "Off center", "The cut does not have to go through the middle.",
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
        make(.pizzaPark, 7, number: 8, "Park exam", "A tighter corridor. Find one clean path.",
             hint: Cut(angle: 0.72, offset: -0.10),
             left: [pep, pep, pep, pepper],
             right: [mush, mush, olive, olive, basil],
             dog: .exclusive([.pepperoni, .pepper]),
             cat: .remainder,
             hints: 1, margin: 0.13),
        make(.pizzaPark, 8, number: 9, "Three and two", "Count both plates and avoid the wrong toppings.",
             hint: Cut(angle: -0.62, offset: 0.12),
             left: [pep, pep, pep, pineapple, pepper],
             right: [mush, mush, olive, olive, corn],
             dog: .counts(
                [CountRule(kind: .pepperoni, min: 3, max: 3), CountRule(kind: .pineapple, min: 1, max: 1)],
                forbidden: [.mushroom, .olive]
             ),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 2, max: 2), CountRule(kind: .olive, min: 2, max: 2), CountRule(kind: .corn, min: 1, max: 1)],
                forbidden: [.pepperoni]
             ),
             cleanCut: true,
             hints: 1, margin: 0.12),
        make(.pizzaPark, 9, number: 10, "Balanced lunch", "Both orders count, and neither slice can be greedy.",
             hint: Cut(angle: 0.28, offset: 0.12),
             left: [pep, pep, pep, onion],
             right: [mush, mush, olive, mozzarella],
             dog: .exclusive([.pepperoni, .onion]),
             cat: .exclusive([.mushroom, .olive, .mozzarella]),
             minArea: 0.38,
             cleanCut: true,
             hints: 1, margin: 0.11),
        make(.pizzaPark, 10, number: 11, "Exact duet", "Two exact recipes must land on the right plates.",
             hint: Cut(angle: 1.02, offset: -0.06),
             left: [pep, pep, pepper, pepper, pineapple],
             right: [mush, mush, mush, onion, mozzarella],
             dog: .counts(
                [CountRule(kind: .pepperoni, min: 2, max: 2), CountRule(kind: .pepper, min: 2, max: 2), CountRule(kind: .pineapple, min: 1, max: 1)],
                forbidden: [.mushroom, .olive]
             ),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 3, max: 3), CountRule(kind: .onion, min: 1, max: 1), CountRule(kind: .mozzarella, min: 1, max: 1)],
                allowOthers: false
             ),
             cleanCut: true,
             hints: 1, margin: 0.10),
        make(.pizzaPark, 11, number: 12, "Park finale", "A tight, fair corridor with two picky guests.",
             hint: Cut(angle: -1.12, offset: 0.04),
             left: [pep, pep, pep, basil, corn],
             right: [mush, mush, onion, mozzarella, mozzarella],
             dog: .exclusive([.pepperoni, .basil, .corn]),
             cat: .exclusive([.mushroom, .onion, .mozzarella]),
             minArea: 0.43,
             cleanCut: true,
             hints: 1, margin: 0.10),
    ]

    private static let berryMeadow: [LevelDef] = [
        make(.berryMeadow, 0, number: 13, "Two strawberries", "The pup wants two strawberries and no cherries.",
             hint: Cut(angle: 0, offset: 0.12),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry], allowOthers: true),
             cat: .remainder,
             hints: 3, margin: 0.20),
        make(.berryMeadow, 1, number: 14, "Leave the cherries", "Same rule, busier tart.",
             hint: Cut(angle: 0.22, offset: 0),
             left: [straw, straw, straw],
             right: [cherry, cherry, blue, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 3)], forbidden: [.cherry]),
             cat: .remainder,
             hints: 2, margin: 0.18),
        make(.berryMeadow, 2, number: 15, "Blue for kitty", "The kitten wants blueberries only.",
             hint: Cut(angle: -0.35, offset: -0.08),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.blueberry], allowOthers: true),
             cat: .exclusive([.blueberry]),
             hints: 2, margin: 0.16),
        make(.berryMeadow, 3, number: 16, "Three cherries", "Count carefully. The rest can wander.",
             hint: Cut(angle: 0.60, offset: 0.14),
             left: [cherry, cherry, cherry],
             right: [straw, straw, blue, blue],
             dog: .exact(.cherry, count: 3, allowOthers: false),
             cat: .remainder,
             hints: 2, margin: 0.16),
        make(.berryMeadow, 4, number: 17, "Diagonal tart", "The easiest path leans.",
             hint: Cut(angle: 0.90, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             hints: 2, margin: 0.15),
        make(.berryMeadow, 5, number: 18, "Offset berries", "More fruit on one side is allowed.",
             hint: Cut(angle: 0, offset: 0.28),
             left: [straw, straw],
             right: [cherry, cherry, cherry, blue, blue, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry], allowOthers: false),
             cat: .remainder,
             hints: 2, margin: 0.15),
        make(.berryMeadow, 6, number: 19, "Mixed bowl", "Strawberries left, cherries right, weave between the blues.",
             hint: Cut(angle: -0.70, offset: -0.06),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 3)], forbidden: [.strawberry]),
             hints: 1, margin: 0.14),
        make(.berryMeadow, 7, number: 20, "Meadow exam", "Two strawberries. Zero cherries. Tighter.",
             hint: Cut(angle: 1.05, offset: 0.10),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             hints: 1, margin: 0.12),
        make(.berryMeadow, 8, number: 21, "Berry ledger", "Count strawberries and cherries on both sides.",
             hint: Cut(angle: -0.92, offset: 0.08),
             left: [straw, straw, straw, blue],
             right: [cherry, cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 3, forbidden: [.cherry]),
             cat: .exact(.cherry, count: 3, forbidden: [.strawberry]),
             cleanCut: true,
             hints: 1, margin: 0.11),
        make(.berryMeadow, 9, number: 22, "Double recipe", "One plate needs two kinds in exact amounts.",
             hint: Cut(angle: 0.48, offset: -0.10),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, blue, blue],
             dog: .counts(
                [CountRule(kind: .strawberry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                allowOthers: false
             ),
             cat: .exact(.cherry, count: 2, forbidden: [.strawberry]),
             minArea: 0.38,
             cleanCut: true,
             hints: 1, margin: 0.11),
        make(.berryMeadow, 10, number: 23, "Twilight berries", "The narrow path separates two mixed recipes.",
             hint: Cut(angle: 1.28, offset: 0.06),
             left: [cherry, cherry, blue, blue],
             right: [straw, straw, straw, blue],
             dog: .counts(
                [CountRule(kind: .cherry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.strawberry]
             ),
             cat: .exact(.strawberry, count: 3, forbidden: [.cherry]),
             cleanCut: true,
             hints: 1, margin: 0.10),
        make(.berryMeadow, 11, number: 24, "Meadow finale", "Exact fruit, forbidden fruit, and fair portions.",
             hint: Cut(angle: -0.35, offset: 0.04),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .counts(
                [CountRule(kind: .strawberry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.cherry]
             ),
             cat: .exact(.cherry, count: 3, forbidden: [.strawberry]),
             minArea: 0.45,
             cleanCut: true,
             hints: 1, margin: 0.10),
    ]

    private static let forestPicnic: [LevelDef] = [
        make(.forestPicnic, 0, number: 25, "Both want", "Pepperoni left. Mushrooms right. Both guests are picky.",
             hint: Cut(angle: 0.18, offset: 0),
             left: [pep, pep, pep, basil],
             right: [mush, mush, mush, olive],
             dog: .exclusive([.pepperoni, .basil]),
             cat: .exclusive([.mushroom, .olive]),
             hints: 2, margin: 0.16),
        make(.forestPicnic, 1, number: 26, "Peppers and olives", "A forest mix with a clean seam.",
             hint: Cut(angle: -0.42, offset: 0.10),
             left: [pepper, pepper, pep],
             right: [olive, olive, olive, mush],
             dog: .exclusive([.pepper, .pepperoni]),
             cat: .exclusive([.olive, .mushroom]),
             hints: 2, margin: 0.15),
        make(.forestPicnic, 2, number: 27, "Tight path", "The toppings sit closer to your route.",
             hint: Cut(angle: 0.80, offset: -0.12),
             left: [pep, pep, olive],
             right: [mush, mush, pepper, basil],
             dog: .exclusive([.pepperoni, .olive]),
             cat: .exclusive([.mushroom, .pepper, .basil], minEach: 1),
             hints: 2, margin: 0.13),
        make(.forestPicnic, 3, number: 28, "Three rules", "Counts, not just kinds.",
             hint: Cut(angle: 0.30, offset: 0.18),
             left: [pep, pep, pep],
             right: [mush, mush, olive, olive, basil],
             dog: .exact(.pepperoni, count: 3, allowOthers: false),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 2, max: 2), CountRule(kind: .olive, min: 2, max: 2)],
                allowOthers: true
             ),
             hints: 2, margin: 0.14),
        make(.forestPicnic, 4, number: 29, "Lay it flat", "A nearly horizontal cut is the honest one.",
             hint: Cut(angle: 1.40, offset: 0),
             left: [pep, pep, pepper, pepper],
             right: [mush, mush, olive, basil],
             dog: .exclusive([.pepperoni, .pepper]),
             cat: .exclusive([.mushroom, .olive, .basil], minEach: 1),
             hints: 1, margin: 0.14),
        make(.forestPicnic, 5, number: 30, "Forest mix", "More toppings. Shape one smart cut.",
             hint: Cut(angle: -0.85, offset: 0.08),
             left: [pep, pep, basil, basil],
             right: [mush, olive, olive, pepper, pepper],
             dog: .exclusive([.pepperoni, .basil]),
             cat: .remainder,
             hints: 1, margin: 0.13),
        make(.forestPicnic, 6, number: 31, "Narrow lane", "Follow the open corridor with your finger.",
             hint: Cut(angle: 0.50, offset: -0.16),
             left: [pep, pep, pep, olive],
             right: [mush, mush, pepper, basil, olive],
             dog: .counts([CountRule(kind: .pepperoni, min: 3, max: 3)], forbidden: [.mushroom, .pepper], allowOthers: true),
             cat: .remainder,
             hints: 1, margin: 0.12),
        make(.forestPicnic, 7, number: 32, "Forest exam", "Both orders, a lean, a little offset.",
             hint: Cut(angle: 1.10, offset: 0.12),
             left: [pep, pepper, pepper, basil],
             right: [mush, mush, olive, olive],
             dog: .exclusive([.pepperoni, .pepper, .basil], minEach: 1),
             cat: .exclusive([.mushroom, .olive]),
             hints: 1, margin: 0.12),
        make(.forestPicnic, 8, number: 33, "Four counts", "Every topping matters on both plates.",
             hint: Cut(angle: 0.68, offset: -0.08),
             left: [pep, pep, pepper, pepper, corn],
             right: [mush, mush, olive, olive, onion],
             dog: .counts(
                [CountRule(kind: .pepperoni, min: 2, max: 2), CountRule(kind: .pepper, min: 2, max: 2), CountRule(kind: .corn, min: 1, max: 1)],
                forbidden: [.mushroom, .olive]
             ),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 2, max: 2), CountRule(kind: .olive, min: 2, max: 2), CountRule(kind: .onion, min: 1, max: 1)],
                forbidden: [.pepperoni, .pepper]
             ),
             cleanCut: true,
             hints: 1, margin: 0.10),
        make(.forestPicnic, 9, number: 34, "Forest balance", "A fair share for two strict recipes.",
             hint: Cut(angle: -0.52, offset: 0.08),
             left: [pep, pep, pep, mozzarella],
             right: [mush, mush, pepper, pineapple],
             dog: .exclusive([.pepperoni, .mozzarella]),
             cat: .exclusive([.mushroom, .pepper, .pineapple]),
             minArea: 0.42,
             cleanCut: true,
             hints: 1, margin: 0.10),
        make(.forestPicnic, 10, number: 35, "Hidden trail", "Ten toppings leave only a slim route.",
             hint: Cut(angle: 1.34, offset: -0.04),
             left: [pep, pep, onion, basil, basil],
             right: [mush, mush, pepper, pepper, corn],
             dog: .counts(
                [CountRule(kind: .pepperoni, min: 2, max: 2), CountRule(kind: .basil, min: 2, max: 2), CountRule(kind: .onion, min: 1, max: 1)],
                forbidden: [.mushroom, .pepper]
             ),
             cat: .counts(
                [CountRule(kind: .mushroom, min: 2, max: 2), CountRule(kind: .pepper, min: 2, max: 2), CountRule(kind: .corn, min: 1, max: 1)],
                forbidden: [.pepperoni, .basil]
             ),
             cleanCut: true,
             hints: 1, margin: 0.09),
        make(.forestPicnic, 11, number: 36, "Forest finale", "The smallest fair corridor in the woods.",
             hint: Cut(angle: -1.02, offset: 0.04),
             left: [pep, pep, pepper, mozzarella],
             right: [mush, mush, olive, pineapple],
             dog: .exclusive([.pepperoni, .pepper, .mozzarella]),
             cat: .exclusive([.mushroom, .olive, .pineapple]),
             minArea: 0.46,
             cleanCut: true,
             hints: 1, margin: 0.09),
    ]

    private static let sunsetBakery: [LevelDef] = [
        make(.sunsetBakery, 0, number: 37, "Fair half", "The pup wants two strawberries. Keep the slices close in size.",
             hint: Cut(angle: 0, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.36,
             hints: 2, margin: 0.16),
        make(.sunsetBakery, 1, number: 38, "Fair tart", "Same berries, a little tilt still counts as fair.",
             hint: Cut(angle: 0.32, offset: 0),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, cherry],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.blueberry]),
             cat: .remainder,
             minArea: 0.36,
             hints: 2, margin: 0.15),
        make(.sunsetBakery, 2, number: 39, "Forty percent", "Neither guest leaves hungry.",
             hint: Cut(angle: -0.25, offset: 0.06),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.40,
             hints: 2, margin: 0.14),
        make(.sunsetBakery, 3, number: 40, "Counts and fairness", "Orders plus a fair split.",
             hint: Cut(angle: 0.55, offset: 0),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 2)], forbidden: [.strawberry]),
             minArea: 0.38,
             hints: 1, margin: 0.14),
        make(.sunsetBakery, 4, number: 41, "Diagonal fair", "Lean the knife. Keep the areas honest.",
             hint: Cut(angle: 0.95, offset: 0),
             left: [straw, straw, cherry],
             right: [blue, blue, blue, cherry],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], allowOthers: true),
             cat: .remainder,
             minArea: 0.40,
             hints: 1, margin: 0.13),
        make(.sunsetBakery, 5, number: 42, "Offset fair", "A slight shift is fine. A greedy slice is not.",
             hint: Cut(angle: 0.15, offset: 0.12),
             left: [straw, straw, blue],
             right: [cherry, cherry, cherry, blue, straw],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.38,
             hints: 1, margin: 0.13),
        make(.sunsetBakery, 6, number: 43, "Busy pie", "More fruit, one freehand cut, still fair.",
             hint: Cut(angle: -0.60, offset: 0),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .counts([CountRule(kind: .strawberry, min: 2, max: 2)], forbidden: [.cherry]),
             cat: .remainder,
             minArea: 0.40,
             hints: 1, margin: 0.12),
        make(.sunsetBakery, 7, number: 44, "Bakery exam", "Both orders, fair slices, a leaning cut.",
             hint: Cut(angle: 1.15, offset: 0.05),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .exact(.strawberry, count: 2, forbidden: [.cherry]),
             cat: .counts([CountRule(kind: .cherry, min: 2, max: 2)], forbidden: [.strawberry]),
             minArea: 0.42,
             hints: 1, margin: 0.12),
        make(.sunsetBakery, 8, number: 45, "Three exact fruits", "Both guests count every berry in a fair slice.",
             hint: Cut(angle: 0.82, offset: 0.06),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .counts(
                [CountRule(kind: .strawberry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.cherry]
             ),
             cat: .exact(.cherry, count: 3, forbidden: [.strawberry]),
             minArea: 0.45,
             cleanCut: true,
             hints: 1, margin: 0.10),
        make(.sunsetBakery, 9, number: 46, "Sunset balance", "Two mixed recipes with almost equal portions.",
             hint: Cut(angle: -0.74, offset: -0.04),
             left: [cherry, cherry, blue, blue],
             right: [straw, straw, straw, blue],
             dog: .counts(
                [CountRule(kind: .cherry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.strawberry]
             ),
             cat: .exact(.strawberry, count: 3, forbidden: [.cherry]),
             minArea: 0.46,
             cleanCut: true,
             hints: 1, margin: 0.09),
        make(.sunsetBakery, 10, number: 47, "Golden sliver", "A tiny angle change can move the wrong berry.",
             hint: Cut(angle: 1.22, offset: 0.05),
             left: [straw, straw, blue],
             right: [cherry, cherry, blue, blue],
             dog: .counts(
                [CountRule(kind: .strawberry, min: 2, max: 2), CountRule(kind: .blueberry, min: 1, max: 1)],
                forbidden: [.cherry]
             ),
             cat: .counts(
                [CountRule(kind: .cherry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.strawberry]
             ),
             minArea: 0.45,
             cleanCut: true,
             hints: 1, margin: 0.09),
        make(.sunsetBakery, 11, number: 48, "Grand picnic", "Exact orders. No forbidden fruit. Nearly perfect halves.",
             hint: Cut(angle: -1.18, offset: 0.03),
             left: [straw, straw, blue, blue],
             right: [cherry, cherry, cherry, blue],
             dog: .counts(
                [CountRule(kind: .strawberry, min: 2, max: 2), CountRule(kind: .blueberry, min: 2, max: 2)],
                forbidden: [.cherry]
             ),
             cat: .counts(
                [CountRule(kind: .cherry, min: 3, max: 3), CountRule(kind: .blueberry, min: 1, max: 1)],
                forbidden: [.strawberry]
             ),
             minArea: 0.47,
             cleanCut: true,
             hints: 1, margin: 0.09),
    ]
}
