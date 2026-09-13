import Foundation

struct Vec2: Equatable, Sendable, Hashable {
    var x: Double
    var y: Double

    static let zero = Vec2(x: 0, y: 0)

    var length: Double { hypot(x, y) }

    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
    static func - (lhs: Vec2, rhs: Vec2) -> Vec2 { Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
    static func * (lhs: Vec2, rhs: Double) -> Vec2 { Vec2(x: lhs.x * rhs, y: lhs.y * rhs) }
    static func / (lhs: Vec2, rhs: Double) -> Vec2 { Vec2(x: lhs.x / rhs, y: lhs.y / rhs) }
}

enum Half: String, Sendable {
    case positive
    case negative
}

/// A cut through the unit-circle dish. Authored hints are straight, while a player's
/// cut may retain the full freehand stroke between its two boundary intersections.
struct Cut: Equatable, Sendable {
    var angle: Double
    var offset: Double
    private(set) var stroke: [Vec2]?

    init(angle: Double, offset: Double) {
        self.angle = angle
        self.offset = offset
        self.stroke = nil
    }

    private init(angle: Double, offset: Double, stroke: [Vec2]) {
        self.angle = angle
        self.offset = offset
        self.stroke = stroke
    }

    static let vertical = Cut(angle: 0, offset: 0)

    var normal: Vec2 { Vec2(x: cos(angle), y: sin(angle)) }
    var tangent: Vec2 { Vec2(x: -sin(angle), y: cos(angle)) }

    var pathPoints: [Vec2] {
        if let stroke { return stroke }
        guard let chord = chord() else { return [] }
        return [chord.0, chord.1]
    }

    var isFreeform: Bool { stroke != nil }

    func signedDistance(_ p: Vec2) -> Double {
        if stroke != nil {
            let distance = Self.distance(from: p, to: pathPoints)
            return halfByPolygon(of: p) == .positive ? distance : -distance
        }
        return p.x * cos(angle) + p.y * sin(angle) - offset
    }

    func half(of p: Vec2, epsilon: Double = 1e-9) -> Half {
        if stroke != nil {
            if Self.distance(from: p, to: pathPoints) <= epsilon { return .positive }
            return halfByPolygon(of: p)
        }
        return signedDistance(p) >= -epsilon ? .positive : .negative
    }

    /// Area of the unit disk on the positive side of the cut, in [0, π].
    var positiveArea: Double {
        if stroke != nil { return areaRatios.positive * .pi }
        let d = min(max(offset, -1), 1)
        return acos(d) - d * sqrt(max(0, 1 - d * d))
    }

    var negativeArea: Double { .pi - positiveArea }

    /// Fraction of the disk on each side.
    var areaRatios: (positive: Double, negative: Double) {
        if stroke != nil {
            let positive = abs(Self.signedArea(of: polygon(for: .positive)))
            let negative = abs(Self.signedArea(of: polygon(for: .negative)))
            let total = positive + negative
            guard total > 1e-9 else { return (0.5, 0.5) }
            return (positive / total, negative / total)
        }
        return (positiveArea / .pi, negativeArea / .pi)
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

    static func following(_ points: [Vec2]) -> Cut? {
        guard points.count >= 2,
              let first = points.first,
              let last = points.last,
              let baseline = Cut.through(first, last),
              (last - first).length > 0.45
        else { return nil }
        return Cut(angle: baseline.angle, offset: baseline.offset, stroke: points)
    }

    func translating(by delta: Double) -> Cut {
        Cut(angle: angle, offset: min(max(offset + delta, -0.92), 0.92))
    }

    func rotating(by delta: Double, around point: Vec2) -> Cut {
        let next = Cut(angle: angle + delta, offset: 0)
        let d = next.normal.x * point.x + next.normal.y * point.y
        return Cut(angle: next.angle, offset: min(max(d, -0.92), 0.92))
    }


    /// A closed polygon for either piece: the finger path plus the matching arc of
    /// the circular crust. Positive is the left side of the directed finger stroke.
    func polygon(for half: Half, arcSamples: Int = 128) -> [Vec2] {
        let curve = pathPoints
        guard let first = curve.first, let last = curve.last, curve.count >= 2 else { return [] }
        if half == .positive {
            return curve + Self.counterclockwiseArc(from: last, to: first, samples: arcSamples)
        }
        return Array(curve.reversed()) + Self.counterclockwiseArc(from: first, to: last, samples: arcSamples)
    }

    func centroid(of half: Half) -> Vec2 {
        Self.centroid(of: polygon(for: half))
    }

    func point(along fraction: Double) -> Vec2 {
        let points = pathPoints
        guard let first = points.first else { return .zero }
        guard points.count > 1 else { return first }
        let lengths = zip(points, points.dropFirst()).map { ($1 - $0).length }
        let total = lengths.reduce(0, +)
        guard total > 1e-9 else { return first }
        let target = min(max(fraction, 0), 1) * total
        var walked = 0.0
        for (index, length) in lengths.enumerated() {
            if walked + length >= target {
                let local = length > 0 ? (target - walked) / length : 0
                return points[index] + (points[index + 1] - points[index]) * local
            }
            walked += length
        }
        return points.last ?? first
    }

    private func halfByPolygon(of point: Vec2) -> Half {
        Self.contains(point, polygon: polygon(for: .positive)) ? .positive : .negative
    }

    private static func counterclockwiseArc(from startPoint: Vec2, to endPoint: Vec2, samples: Int) -> [Vec2] {
        var start = atan2(startPoint.y, startPoint.x)
        var end = atan2(endPoint.y, endPoint.x)
        while end <= start { end += 2 * .pi }
        if end - start > 2 * .pi { start += 2 * .pi }
        let count = max(8, Int(ceil(Double(samples) * (end - start) / (2 * .pi))))
        return (1...count).map { index in
            let angle = start + (end - start) * Double(index) / Double(count)
            return Vec2(x: cos(angle), y: sin(angle))
        }
    }

    private static func contains(_ point: Vec2, polygon: [Vec2]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        var previous = polygon.last!
        for current in polygon {
            let crosses = (current.y > point.y) != (previous.y > point.y)
            if crosses {
                let x = (previous.x - current.x) * (point.y - current.y)
                    / (previous.y - current.y) + current.x
                if point.x < x { inside.toggle() }
            }
            previous = current
        }
        return inside
    }

    private static func distance(from point: Vec2, to points: [Vec2]) -> Double {
        guard points.count > 1 else { return .infinity }
        return zip(points, points.dropFirst()).map { a, b in
            let delta = b - a
            let denominator = delta.x * delta.x + delta.y * delta.y
            guard denominator > 1e-12 else { return (point - a).length }
            let projection = ((point.x - a.x) * delta.x + (point.y - a.y) * delta.y) / denominator
            let t = min(max(projection, 0), 1)
            return (point - (a + delta * t)).length
        }.min() ?? .infinity
    }

    private static func signedArea(of polygon: [Vec2]) -> Double {
        guard polygon.count >= 3 else { return 0 }
        let closed = Array(polygon.dropFirst()) + [polygon[0]]
        return zip(polygon, closed)
            .reduce(0) { $0 + $1.0.x * $1.1.y - $1.1.x * $1.0.y } / 2
    }

    private static func centroid(of polygon: [Vec2]) -> Vec2 {
        guard polygon.count >= 3 else { return .zero }
        var crossSum = 0.0
        var xSum = 0.0
        var ySum = 0.0
        for index in polygon.indices {
            let a = polygon[index]
            let b = polygon[(index + 1) % polygon.count]
            let cross = a.x * b.y - b.x * a.y
            crossSum += cross
            xSum += (a.x + b.x) * cross
            ySum += (a.y + b.y) * cross
        }
        guard abs(crossSum) > 1e-9 else { return .zero }
        return Vec2(x: xSum / (3 * crossSum), y: ySum / (3 * crossSum))
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

enum SwipeGeometry {
    /// Converts the full finger trail into a boundary-to-boundary freeform cut.
    /// Short strokes, strokes that miss the food, and self-intersections are ignored.
    static func cut(
        from start: CGPoint,
        to end: CGPoint,
        center: CGPoint,
        radius: CGFloat
    ) -> Cut? {
        cut(from: [start, end], center: center, radius: radius)
    }

    static func cut(from viewPoints: [CGPoint], center: CGPoint, radius: CGFloat) -> Cut? {
        guard radius > 1, viewPoints.count >= 2 else { return nil }
        let raw = deduplicated(
            viewPoints.map { DishSpace.fromView($0, center: center, radius: radius) },
            minimumDistance: 0.012
        )
        guard raw.count >= 2, pathLength(raw) >= 0.55 else { return nil }
        var clipped = clippedToCircle(raw)
        guard clipped.count >= 2 else { return nil }

        clipped = deduplicated(clipped, minimumDistance: 0.018)
        guard clipped.count >= 2 else { return nil }
        clipped[0] = projectedToCircle(clipped[0])
        clipped[clipped.count - 1] = projectedToCircle(clipped[clipped.count - 1])
        guard (clipped.last! - clipped.first!).length > 0.45,
              !selfIntersects(clipped)
        else { return nil }
        return Cut.following(clipped)
    }

    static func minimumDistance(from point: Vec2, toViewPoints points: [CGPoint], center: CGPoint, radius: CGFloat) -> Double {
        let normalized = points.map { DishSpace.fromView($0, center: center, radius: radius) }
        guard normalized.count > 1 else { return .infinity }
        return zip(normalized, normalized.dropFirst()).map { a, b in
            distance(point, toSegmentFrom: a, to: b)
        }.min() ?? .infinity
    }

    private static func clippedToCircle(_ points: [Vec2]) -> [Vec2] {
        var pieces: [[Vec2]] = []
        for (a, b) in zip(points, points.dropFirst()) {
            var values = [0.0, 1.0]
            values.append(contentsOf: circleIntersections(from: a, to: b))
            values = Array(Set(values.map { (min(max($0, 0), 1) * 1_000_000).rounded() / 1_000_000 })).sorted()
            for (lower, upper) in zip(values, values.dropFirst()) where upper - lower > 1e-7 {
                let midpoint = a + (b - a) * ((lower + upper) / 2)
                guard midpoint.length <= 1.000_1 else { continue }
                let start = a + (b - a) * lower
                let end = a + (b - a) * upper
                if let last = pieces.indices.last, let tail = pieces[last].last, (tail - start).length < 0.01 {
                    if (tail - end).length > 1e-7 { pieces[last].append(end) }
                } else {
                    pieces.append([start, end])
                }
            }
        }
        guard pieces.count == 1, var result = pieces.first else { return [] }
        guard result.count >= 2 else { return [] }

        if result[0].length < 0.999 {
            let direction = result[0] - result[1]
            guard let boundary = rayCircleIntersection(origin: result[0], direction: direction) else { return [] }
            result.insert(boundary, at: 0)
        }
        if result[result.count - 1].length < 0.999 {
            let direction = result[result.count - 1] - result[result.count - 2]
            guard let boundary = rayCircleIntersection(origin: result[result.count - 1], direction: direction) else { return [] }
            result.append(boundary)
        }
        return result
    }

    private static func circleIntersections(from a: Vec2, to b: Vec2) -> [Double] {
        let delta = b - a
        let aa = delta.x * delta.x + delta.y * delta.y
        guard aa > 1e-12 else { return [] }
        let bb = 2 * (a.x * delta.x + a.y * delta.y)
        let cc = a.x * a.x + a.y * a.y - 1
        let discriminant = bb * bb - 4 * aa * cc
        guard discriminant >= 0 else { return [] }
        let root = sqrt(discriminant)
        return [(-bb - root) / (2 * aa), (-bb + root) / (2 * aa)]
            .filter { $0 > 1e-7 && $0 < 1 - 1e-7 }
    }

    private static func rayCircleIntersection(origin: Vec2, direction: Vec2) -> Vec2? {
        let aa = direction.x * direction.x + direction.y * direction.y
        guard aa > 1e-12 else { return nil }
        let bb = 2 * (origin.x * direction.x + origin.y * direction.y)
        let cc = origin.x * origin.x + origin.y * origin.y - 1
        let discriminant = bb * bb - 4 * aa * cc
        guard discriminant >= 0 else { return nil }
        let root = sqrt(discriminant)
        let candidates = [(-bb - root) / (2 * aa), (-bb + root) / (2 * aa)].filter { $0 > 1e-7 }
        guard let t = candidates.min() else { return nil }
        return origin + direction * t
    }

    private static func projectedToCircle(_ point: Vec2) -> Vec2 {
        guard point.length > 1e-9 else { return Vec2(x: 1, y: 0) }
        return point / point.length
    }

    private static func deduplicated(_ points: [Vec2], minimumDistance: Double) -> [Vec2] {
        guard let first = points.first else { return [] }
        var result = [first]
        for point in points.dropFirst() where (point - result.last!).length >= minimumDistance {
            result.append(point)
        }
        if let last = points.last, (last - result.last!).length > 1e-9 { result.append(last) }
        return result
    }

    private static func pathLength(_ points: [Vec2]) -> Double {
        zip(points, points.dropFirst()).reduce(0) { $0 + ($1.1 - $1.0).length }
    }

    private static func distance(_ point: Vec2, toSegmentFrom a: Vec2, to b: Vec2) -> Double {
        let delta = b - a
        let denominator = delta.x * delta.x + delta.y * delta.y
        guard denominator > 1e-12 else { return (point - a).length }
        let projection = ((point.x - a.x) * delta.x + (point.y - a.y) * delta.y) / denominator
        let t = min(max(projection, 0), 1)
        return (point - (a + delta * t)).length
    }

    private static func selfIntersects(_ points: [Vec2]) -> Bool {
        guard points.count >= 4 else { return false }
        for first in 0..<(points.count - 2) {
            for second in (first + 2)..<(points.count - 1) {
                if first == 0 && second == points.count - 2 { continue }
                if segmentsIntersect(points[first], points[first + 1], points[second], points[second + 1]) {
                    return true
                }
            }
        }
        return false
    }

    private static func segmentsIntersect(_ a: Vec2, _ b: Vec2, _ c: Vec2, _ d: Vec2) -> Bool {
        func cross(_ p: Vec2, _ q: Vec2, _ r: Vec2) -> Double {
            (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x)
        }
        let abC = cross(a, b, c)
        let abD = cross(a, b, d)
        let cdA = cross(c, d, a)
        let cdB = cross(c, d, b)
        return abC * abD < -1e-9 && cdA * cdB < -1e-9
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
        if cut.isFreeform {
            return (cut.centroid(of: .positive), cut.centroid(of: .negative))
        }
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
