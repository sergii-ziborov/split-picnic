import Foundation

enum DishLayout {
    static func build(level: LevelDef, seed: UInt64) -> [Topping] {
        var rng = SeededRNG(seed: seed &+ UInt64(level.number) &* 1_000_003)
        let dogHalf = SliceGeometry.dogHalf(for: level.hint)
        let catHalf: Half = dogHalf == .positive ? .negative : .positive
        var placed: [Topping] = []
        var id = 0

        func add(_ kinds: [ToppingKind], half: Half) {
            for kind in kinds {
                if let p = sample(
                    kind: kind,
                    half: half,
                    cut: level.hint,
                    margin: level.margin,
                    existing: placed,
                    rng: &rng
                ) {
                    placed.append(Topping(id: id, kind: kind, position: p, radius: radius(for: kind)))
                    id += 1
                }
            }
        }

        add(level.leftKinds, half: dogHalf)
        add(level.rightKinds, half: catHalf)
        return placed
    }

    static func radius(for kind: ToppingKind) -> Double {
        switch kind {
        case .pepperoni: 0.085
        case .mushroom: 0.08
        case .olive: 0.055
        case .pepper: 0.07
        case .basil: 0.07
        case .strawberry: 0.08
        case .blueberry: 0.05
        case .cherry: 0.06
        }
    }

    private static func sample(
        kind: ToppingKind,
        half: Half,
        cut: Cut,
        margin: Double,
        existing: [Topping],
        rng: inout SeededRNG
    ) -> Vec2? {
        let r = radius(for: kind)
        let need = margin + r
        let inner = 0.78 - r
        for _ in 0..<120 {
            let theta = rng.nextDouble() * 2 * .pi
            let rad = sqrt(rng.nextDouble()) * inner
            let p = Vec2(x: cos(theta) * rad, y: sin(theta) * rad)
            let d = cut.signedDistance(p)
            switch half {
            case .positive:
                if d < need { continue }
            case .negative:
                if d > -need { continue }
            }
            if p.length + r > 0.84 { continue }
            let clash = existing.contains { other in
                let gap = (other.position - p).length
                return gap < other.radius + r + 0.035
            }
            if clash { continue }
            return p
        }
        return fallback(kind: kind, half: half, cut: cut, existing: existing, rng: &rng)
    }

    private static func fallback(
        kind: ToppingKind,
        half: Half,
        cut: Cut,
        existing: [Topping],
        rng: inout SeededRNG
    ) -> Vec2? {
        let n = cut.normal
        let sign: Double = half == .positive ? 1 : -1
        let along = min(max(cut.offset + sign * 0.42, -0.55), 0.55)
        let jitter = rng.nextDouble(in: -0.28...0.28)
        var p = n * along + cut.tangent * jitter
        if p.length > 0.7 {
            p = p * (0.7 / p.length)
        }
        if existing.contains(where: { ($0.position - p).length < 0.14 }) {
            p = p + cut.tangent * (sign * 0.18)
        }
        return p
    }
}
