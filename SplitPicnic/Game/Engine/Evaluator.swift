import Foundation

enum SliceEvaluator {
    static func counts(in toppings: [Topping], cut: Cut, half: Half) -> [ToppingKind: Int] {
        var result: [ToppingKind: Int] = [:]
        for topping in toppings where cut.half(of: topping.position) == half {
            result[topping.kind, default: 0] += 1
        }
        return result
    }

    static func matches(_ order: GuestOrder, counts: [ToppingKind: Int]) -> Bool {
        let total = counts.values.reduce(0, +)
        if order.requireSome && total == 0 { return false }
        if order.isRemainder { return true }

        for rule in order.required {
            if !rule.matches(counts[rule.kind, default: 0]) { return false }
        }
        for kind in order.forbidden where counts[kind, default: 0] > 0 {
            return false
        }
        if !order.allowOthers {
            let allowed = Set(order.required.map(\.kind))
            for (kind, count) in counts where count > 0 && !allowed.contains(kind) {
                return false
            }
        }
        return true
    }

    static func areaOK(cut: Cut, minRatio: Double?) -> Bool {
        guard let minRatio else { return true }
        let ratios = cut.areaRatios
        return ratios.positive + 1e-9 >= minRatio && ratios.negative + 1e-9 >= minRatio
    }

    static func isClean(toppings: [Topping], cut: Cut, required: Bool) -> Bool {
        guard required else { return true }
        // Topping artwork is intentionally larger than its layout collision radius.
        // This buffer makes a visually touching swipe count as a hit as well.
        return toppings.allSatisfy { topping in
            abs(cut.signedDistance(topping.position)) > topping.radius * 1.55
        }
    }

    static func evaluate(
        toppings: [Topping],
        cut: Cut,
        dog: GuestOrder,
        cat: GuestOrder,
        minAreaRatio: Double?,
        requiresCleanCut: Bool,
        attempts: Int,
        hintsUsed: Int
    ) -> SliceOutcome {
        let dogHalf = SliceGeometry.dogHalf(for: cut)
        let catHalf: Half = dogHalf == .positive ? .negative : .positive
        let dogCounts = counts(in: toppings, cut: cut, half: dogHalf)
        let catCounts = counts(in: toppings, cut: cut, half: catHalf)
        let area = areaOK(cut: cut, minRatio: minAreaRatio)
        let clean = isClean(toppings: toppings, cut: cut, required: requiresCleanCut)
        let dogHappy = matches(dog, counts: dogCounts)
        let catHappy = matches(cat, counts: catCounts)
        let success = dogHappy && catHappy && area && clean
        return SliceOutcome(
            dogHappy: dogHappy,
            catHappy: catHappy,
            dogCounts: dogCounts,
            catCounts: catCounts,
            dogHalf: dogHalf,
            areaOK: area,
            cleanCut: clean,
            positiveArea: cut.areaRatios.positive,
            negativeArea: cut.areaRatios.negative,
            stars: success ? StarRating.stars(attempts: attempts, hintsUsed: hintsUsed) : 0
        )
    }
}
