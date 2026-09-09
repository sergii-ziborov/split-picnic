import Foundation

struct Vec2: Equatable, Sendable, Hashable {
    var x: Double
    var y: Double

    static let zero = Vec2(x: 0, y: 0)

    var length: Double { hypot(x, y) }

    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func - (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func * (lhs: Vec2, rhs: Double) -> Vec2 { Vec2(x: lhs.x * rhs, y: lhs.y * rhs) }
}

enum Half: String, Sendable {
    case positive
    case negative
}

/// A straight cut through the unit-circle dish.
/// The line is `normal · p = offset`. Angle 0 is a vertical line (normal points +X).
struct Cut: Equatable, Sendable {
    var angle: Double
    var offset: Double

    static let vertical = Cut(angle: 0, offset: 0)

    var normal: Vec2 { Vec2(x: cos(angle), y: sin(angle)) }
    var tangent: Vec2 { Vec2(x: -sin(angle), y: cos(angle)) }

    func signedDistance(_ p: Vec2) -> Double {
        p.x * cos(angle) + p.y * sin(angle) - offset
    }

    func half(of p: Vec2, epsilon: Double = 1e-9) -> Half {
        signedDistance(p) >= -epsilon ? .positive : .negative
    }

    /// Area of the unit disk on the positive side of the cut, in [0, π].
    var positiveArea: Double {
        let d = min(max(offset, -1), 1)
        return acos(d) - d * sqrt(max(0, 1 - d * d))
    }

    var negativeArea: Double { .pi - positiveArea }

    /// Fraction of the disk on each side.
    var areaRatios: (positive: Double, negative: Double) {
        (positiveArea / .pi, negativeArea / .pi)
    }

    func chord(radius: Double = 1) -> (Vec2, Vec2)? {
        let h2 = radius * radius - offset * offset
        guard h2 > 1e-8 else { return nil }
        let h = sqrt(h2)
        let c = normal * offset
        let t = tangent * h
        return (c + t, c - t)
    }

    static func through(_ a: Vec2, _ b: Vec2) -> Cut? {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let len = hypot(dx, dy)
        guard len > 1e-6 else { return nil }
        let nx = -dy / len
        let ny = dx / len
        let angle = atan2(ny, nx)
        let offset = nx * a.x + ny * a.y
        return Cut(angle: angle, offset: offset)
    }

    func translating(by delta: Double) -> Cut {
        Cut(angle: angle, offset: min(max(offset + delta, -0.92), 0.92))
    }

    func rotating(by delta: Double, around point: Vec2) -> Cut {
        let next = Cut(angle: angle + delta, offset: 0)
        let d = next.normal.x * point.x + next.normal.y * point.y
        return Cut(angle: next.angle, offset: min(max(d, -0.92), 0.92))
    }
}

enum DishSpace {
    static func toView(_ p: Vec2, center: CGPoint, radius: CGFloat) -> CGPoint {
        CGPoint(x: center.x + CGFloat(p.x) * radius, y: center.y - CGFloat(p.y) * radius)
    }

    static func fromView(_ p: CGPoint, center: CGPoint, radius: CGFloat) -> Vec2 {
        guard radius > 1 else { return .zero }
        return Vec2(
            x: Double((p.x - center.x) / radius),
            y: Double((center.y - p.y) / radius)
        )
    }
}

enum SliceGeometry {
    /// The half whose centroid sits further left on screen is the dog's plate.
    static func dogHalf(for cut: Cut) -> Half {
        let (pos, neg) = centroids(cut)
        if abs(pos.x - neg.x) < 1e-6 {
            return cut.normal.x >= 0 ? .negative : .positive
        }
        return pos.x < neg.x ? .positive : .negative
    }

    static func centroids(_ cut: Cut) -> (positive: Vec2, negative: Vec2) {
        let d = min(max(cut.offset, -0.999), 0.999)
        let posAlong = centroidAlongNormal(offset: d)
        let negAlong = -centroidAlongNormal(offset: -d)
        let n = cut.normal
        return (
            n * posAlong,
            n * negAlong
        )
    }

    /// Distance of the positive-half centroid from the origin, along the normal.
    /// Unit disk, cut at x = d.
    static func centroidAlongNormal(offset d: Double) -> Double {
        let area = acos(d) - d * sqrt(max(0, 1 - d * d))
        guard area > 1e-9 else { return d }
        let numerator = (2.0 / 3.0) * pow(max(0, 1 - d * d), 1.5)
        return numerator / area
    }

    static func slideOffset(cut: Cut, half: Half, amount: Double) -> Vec2 {
        let n = cut.normal
        return half == .positive ? n * amount : n * -amount
    }
}
