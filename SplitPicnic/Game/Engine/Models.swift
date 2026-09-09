import Foundation

enum ToppingKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case pepperoni
    case mushroom
    case olive
    case pepper
    case basil
    case strawberry
    case blueberry
    case cherry

    var id: String { rawValue }

    var isPizza: Bool {
        switch self {
        case .pepperoni, .mushroom, .olive, .pepper, .basil: true
        default: false
        }
    }

    var isBerry: Bool {
        switch self {
        case .strawberry, .blueberry, .cherry: true
        default: false
        }
    }
}

enum DishKind: String, Codable, Sendable {
    case pizza
    case berryPie
}

enum GuestID: String, Codable, Sendable {
    case dog
    case cat
}

struct Topping: Identifiable, Equatable, Sendable {
    var id: Int
    var kind: ToppingKind
    var position: Vec2
    var radius: Double
}

struct CountRule: Equatable, Sendable {
    var kind: ToppingKind
    var min: Int
    var max: Int

    func matches(_ count: Int) -> Bool { (min...max).contains(count) }
}

struct GuestOrder: Equatable, Sendable {
    var required: [CountRule]
    var forbidden: Set<ToppingKind>
    var allowOthers: Bool
    var isRemainder: Bool
    var requireSome: Bool

    static func exclusive(_ kinds: [ToppingKind], minEach: Int = 1) -> GuestOrder {
        GuestOrder(
            required: kinds.map { CountRule(kind: $0, min: minEach, max: 99) },
            forbidden: [],
            allowOthers: false,
            isRemainder: false,
            requireSome: true
        )
    }

    static func exact(_ kind: ToppingKind, count: Int, forbidden: Set<ToppingKind> = [], allowOthers: Bool = true) -> GuestOrder {
        GuestOrder(
            required: [CountRule(kind: kind, min: count, max: count)],
            forbidden: forbidden,
            allowOthers: allowOthers,
            isRemainder: false,
            requireSome: true
        )
    }

    static func counts(_ rules: [CountRule], forbidden: Set<ToppingKind> = [], allowOthers: Bool = true) -> GuestOrder {
        GuestOrder(
            required: rules,
            forbidden: forbidden,
            allowOthers: allowOthers,
            isRemainder: false,
            requireSome: true
        )
    }

    static let remainder = GuestOrder(
        required: [],
        forbidden: [],
        allowOthers: true,
        isRemainder: true,
        requireSome: true
    )
}

struct LevelDef: Identifiable, Equatable, Sendable {
    var world: WorldID
    var index: Int
    var number: Int
    var name: String
    var blurb: String
    var dish: DishKind
    var hint: Cut
    var leftKinds: [ToppingKind]
    var rightKinds: [ToppingKind]
    var dog: GuestOrder
    var cat: GuestOrder
    var minAreaRatio: Double?
    var hints: Int
    var margin: Double

    var id: String { "\(world.rawValue)-\(index)" }
}

enum WorldID: String, Codable, CaseIterable, Sendable, Identifiable {
    case pizzaPark
    case berryMeadow
    case forestPicnic
    case sunsetBakery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pizzaPark: "Pizza Park"
        case .berryMeadow: "Berry Meadow"
        case .forestPicnic: "Forest Picnic"
        case .sunsetBakery: "Sunset Bakery"
        }
    }

    var subtitle: String {
        switch self {
        case .pizzaPark: "One slice. Two toppings. Learn the cut."
        case .berryMeadow: "Count the berries. Leave the cherries."
        case .forestPicnic: "Both guests have a real order."
        case .sunsetBakery: "Fair slices, still one line."
        }
    }

    var backgroundAsset: String {
        switch self {
        case .pizzaPark: "PicnicBackground"
        case .berryMeadow: "BerryBackground"
        case .forestPicnic: "ForestBackground"
        case .sunsetBakery: "BakeryBackground"
        }
    }

    var dish: DishKind {
        switch self {
        case .pizzaPark, .forestPicnic: .pizza
        case .berryMeadow, .sunsetBakery: .berryPie
        }
    }

    var starsToUnlock: Int {
        switch self {
        case .pizzaPark: 0
        case .berryMeadow: 8
        case .forestPicnic: 16
        case .sunsetBakery: 28
        }
    }
}

enum ThemeID: String, Codable, CaseIterable, Sendable, Identifiable {
    case pizzaParty
    case berryPicnic
    case forestFeast
    case bakeryDay
    case sunnyBeach
    case harvestTable

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pizzaParty: "Pizza Party"
        case .berryPicnic: "Berry Picnic"
        case .forestFeast: "Forest Feast"
        case .bakeryDay: "Bakery Day"
        case .sunnyBeach: "Sunny Beach"
        case .harvestTable: "Harvest Table"
        }
    }

    var starsToUnlock: Int {
        switch self {
        case .pizzaParty: 0
        case .berryPicnic: 6
        case .forestFeast: 20
        case .bakeryDay: 25
        case .sunnyBeach: 30
        case .harvestTable: 30
        }
    }

    var cloth: (red: Double, green: Double, blue: Double) {
        switch self {
        case .pizzaParty: (0.86, 0.22, 0.22)
        case .berryPicnic: (0.55, 0.18, 0.42)
        case .forestFeast: (0.22, 0.42, 0.28)
        case .bakeryDay: (0.78, 0.48, 0.28)
        case .sunnyBeach: (0.22, 0.55, 0.78)
        case .harvestTable: (0.82, 0.42, 0.16)
        }
    }
}

enum PlateID: String, Codable, CaseIterable, Sendable, Identifiable {
    case paw
    case heart
    case daisy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paw: "Paw Plate"
        case .heart: "Heart Plate"
        case .daisy: "Daisy Plate"
        }
    }

    var starsToUnlock: Int {
        switch self {
        case .paw: 0
        case .heart: 10
        case .daisy: 15
        }
    }
}

struct PlayContext: Equatable, Sendable {
    var world: WorldID
    var levelIndex: Int
    var seed: UInt64
    var isDaily: Bool
    var theme: ThemeID
    var plate: PlateID

    var level: LevelDef { LevelCatalog.level(world: world, index: levelIndex) }
}

struct SliceOutcome: Equatable, Sendable {
    var dogHappy: Bool
    var catHappy: Bool
    var dogCounts: [ToppingKind: Int]
    var catCounts: [ToppingKind: Int]
    var dogHalf: Half
    var areaOK: Bool
    var positiveArea: Double
    var negativeArea: Double
    var stars: Int

    var success: Bool { dogHappy && catHappy && areaOK }
}

struct RoundOutcome: Equatable, Sendable {
    var stars: Int
    var attempts: Int
    var hintsUsed: Int
    var world: WorldID
    var levelIndex: Int
    var isDaily: Bool
    var dogHappy: Bool
    var catHappy: Bool
    var areaOK: Bool
}

enum StarRating {
    static func stars(attempts: Int, hintsUsed: Int) -> Int {
        if attempts <= 1 && hintsUsed == 0 { return 3 }
        if attempts <= 1 { return 2 }
        if attempts <= 2 && hintsUsed == 0 { return 2 }
        return 1
    }
}

struct ProgressState: Codable, Equatable, Sendable {
    var starsByLevel: [String: Int]
    var totalSolves: Int
    var selectedTheme: ThemeID
    var selectedPlate: PlateID
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticsEnabled: Bool
    var reduceMotion: Bool
    var language: AppLanguage
    var tutorialSeen: Bool
    var lastDailyClaim: String?
    var dailyStreak: Int
    var lastDailyDay: String?

    static let fresh = ProgressState(
        starsByLevel: [:],
        totalSolves: 0,
        selectedTheme: .pizzaParty,
        selectedPlate: .paw,
        soundEnabled: true,
        musicEnabled: true,
        hapticsEnabled: true,
        reduceMotion: false,
        language: .english,
        tutorialSeen: false,
        lastDailyClaim: nil,
        dailyStreak: 0,
        lastDailyDay: nil
    )

    var totalStars: Int { starsByLevel.values.reduce(0, +) }

    func stars(for level: LevelDef) -> Int { starsByLevel[level.id] ?? 0 }

    func isUnlocked(_ world: WorldID) -> Bool { totalStars >= world.starsToUnlock }

    func isThemeUnlocked(_ theme: ThemeID) -> Bool { totalStars >= theme.starsToUnlock }

    func isPlateUnlocked(_ plate: PlateID) -> Bool { totalStars >= plate.starsToUnlock }

    func clearedCount(in world: WorldID) -> Int {
        LevelCatalog.levels(for: world).filter { (starsByLevel[$0.id] ?? 0) > 0 }.count
    }

    func nextPlayable() -> (WorldID, Int) {
        for world in WorldID.allCases where isUnlocked(world) {
            let levels = LevelCatalog.levels(for: world)
            if let idx = levels.firstIndex(where: { (starsByLevel[$0.id] ?? 0) == 0 }) {
                return (world, idx)
            }
        }
        return (.pizzaPark, 0)
    }

    mutating func record(level: LevelDef, stars: Int, daily: Bool) {
        let previous = starsByLevel[level.id] ?? 0
        starsByLevel[level.id] = max(previous, stars)
        totalSolves += 1
        if daily {
            let stamp = DailyStamp.today
            if lastDailyClaim != stamp {
                if lastDailyDay == DailyStamp.yesterday {
                    dailyStreak += 1
                } else if lastDailyClaim != stamp {
                    dailyStreak = 1
                }
                lastDailyClaim = stamp
                lastDailyDay = stamp
            }
        }
    }
}

enum DailyStamp {
    static var today: String { format(Date()) }

    static var yesterday: String {
        format(Date().addingTimeInterval(-86_400))
    }

    static func format(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    static func secondsUntilReset(now: Date = Date()) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let next = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) ?? now.addingTimeInterval(86_400)
        return max(0, Int(next.timeIntervalSince(now)))
    }
}

enum AppLanguage: String, Codable, CaseIterable, Sendable, Identifiable {
    case english
    case russian
    case ukrainian

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .russian: "Русский"
        case .ukrainian: "Українська"
        }
    }
}
