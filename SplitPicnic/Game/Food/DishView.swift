import SwiftUI

struct HalfDishShape: Shape {
    var cut: Cut
    var keepPositive: Bool

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let half: Half = keepPositive ? .positive : .negative
        let pts = cut.polygon(for: half).map {
            DishSpace.toView($0, center: center, radius: radius)
        }
        guard pts.count >= 3 else { return Path() }
        var path = Path()
        path.move(to: pts[0])
        for p in pts.dropFirst() { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}

struct DishCanvas: View {
    var kind: DishKind
    var toppings: [Topping]
    var cut: Cut?
    var split: Double
    var pizzaBaseAsset: String = "PizzaBaseWarm"
    var hideToppings: Bool = false
    var showBoard: Bool = true
    var showFood: Bool = true

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let board = side * 0.50
            let food = side * 0.42

            ZStack {
                if showBoard {
                    boardLayer(radius: board)
                }
                if showFood {
                    foodLayer(radius: food)
                }
                if showFood && !hideToppings {
                    toppingsLayer(center: center, radius: food)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }

    private func boardLayer(radius: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(red: 0.76, green: 0.55, blue: 0.32),
                        Color(red: 0.52, green: 0.34, blue: 0.18),
                    ],
                    center: .center,
                    startRadius: 4,
                    endRadius: radius
                )
            )
            .overlay(Circle().stroke(Color(red: 0.40, green: 0.24, blue: 0.12), lineWidth: 5))
            .frame(width: radius * 2, height: radius * 2)
            .shadow(color: .black.opacity(0.28), radius: 14, y: 8)
    }

    private func foodLayer(radius: CGFloat) -> some View {
        Image(kind == .pizza ? pizzaBaseAsset : "PieBase")
            .resizable()
            .scaledToFit()
            .frame(width: radius * 2, height: radius * 2)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.48), .clear, .black.opacity(0.24)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: radius * 2 - 3, height: radius * 2 - 3)
            }
            .shadow(color: .black.opacity(0.22), radius: 7, y: 5)
    }

    private func toppingsLayer(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(toppings) { topping in
            let p = DishSpace.toView(topping.position, center: center, radius: radius)
            let size = CGFloat(topping.radius) * radius * 3.4
            ToppingSprite(kind: topping.kind)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(Double((topping.id * 47) % 360)))
                .position(p)
        }
    }
}

struct SplitDishView: View {
    var kind: DishKind
    var toppings: [Topping]
    var cut: Cut
    var progress: Double
    var plate: PlateID
    var pizzaBaseAsset: String = "PizzaBaseWarm"

    var body: some View {
        GeometryReader { geo in
            // Slide in dish-relative units. The old fixed 200-point conversion
            // made a large pizza fly apart and exposed most of the board.
            let amount = progress * 0.14
            ZStack {
                DishCanvas(
                    kind: kind,
                    toppings: [],
                    cut: nil,
                    split: 0,
                    hideToppings: true,
                    showFood: false
                )

                if kind == .pizza {
                    CheeseStretchView(cut: cut, progress: progress)
                }

                half(keepPositive: true, amount: amount, in: geo.size)
                half(keepPositive: false, amount: amount, in: geo.size)
            }
        }
    }

    private func half(keepPositive: Bool, amount: Double, in size: CGSize) -> some View {
        let half: Half = keepPositive ? .positive : .negative
        let slide = SliceGeometry.slideOffset(cut: cut, half: half, amount: amount)
        let foodRadius = min(size.width, size.height) * 0.42
        let px = CGFloat(slide.x) * foodRadius
        let py = CGFloat(-slide.y) * foodRadius
        let shape = HalfDishShape(cut: cut, keepPositive: keepPositive)
        let filtered = toppings.filter { cut.half(of: $0.position) == half }
        let depth = CGFloat(progress) * 8

        return ZStack {
            DishCanvas(
                kind: kind,
                toppings: [],
                cut: cut,
                split: 0,
                pizzaBaseAsset: pizzaBaseAsset,
                hideToppings: true,
                showBoard: false
            )
            .brightness(-0.24)
            .saturation(1.12)
            .clipShape(shape)
            .offset(x: px, y: py + depth)

            DishCanvas(
                kind: kind,
                toppings: filtered,
                cut: cut,
                split: 0,
                pizzaBaseAsset: pizzaBaseAsset,
                showBoard: false
            )
            .clipShape(shape)
            .offset(x: px, y: py)

            CutEdgeView(kind: kind, cut: cut, keepPositive: keepPositive, progress: progress)
                .offset(x: px, y: py + depth * 0.34)
        }
        .shadow(color: .black.opacity(0.18 * progress), radius: 7, y: 5)
    }
}

private struct CutEdgeView: View {
    var kind: DishKind
    var cut: Cut
    var keepPositive: Bool
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side * 0.42
            let points = cut.pathPoints.map {
                DishSpace.toView($0, center: center, radius: radius)
            }
            if let first = points.first, points.count >= 2 {
                let line = Path { path in
                    path.move(to: first)
                    for point in points.dropFirst() { path.addLine(to: point) }
                }
                sidewallPath(points: cut.pathPoints, center: center, radius: radius)
                    .fill(
                        LinearGradient(
                            colors: kind == .pizza
                                ? [Color(red: 0.98, green: 0.78, blue: 0.47), Color(red: 0.68, green: 0.35, blue: 0.15)]
                                : [Color(red: 0.96, green: 0.64, blue: 0.62), Color(red: 0.52, green: 0.23, blue: 0.27)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.22), radius: 2, y: 2)
                line
                    .stroke(
                        kind == .pizza
                            ? Color(red: 1, green: 0.87, blue: 0.61).opacity(0.8)
                            : Color(red: 1, green: 0.76, blue: 0.72).opacity(0.8),
                        lineWidth: 1.2
                    )

                ForEach(0..<18, id: \.self) { index in
                    let fraction = Double(index + 1) / 19
                    let point = DishSpace.toView(cut.point(along: fraction), center: center, radius: radius)
                    let sign: CGFloat = keepPositive ? 1 : -1
                    let jitter = CGFloat((index * 7) % 5) * 0.7
                    Circle()
                        .fill(
                            kind == .pizza
                                ? (index.isMultiple(of: 3) ? Color(red: 0.67, green: 0.32, blue: 0.12) : Color(red: 1, green: 0.85, blue: 0.55))
                                : Color(red: 0.97, green: 0.72, blue: 0.67)
                        )
                        .frame(width: index.isMultiple(of: 4) ? 3 : 2, height: index.isMultiple(of: 4) ? 3 : 2)
                        .position(
                            x: point.x + CGFloat(cut.normal.x) * sign * (3 + jitter),
                            y: point.y - CGFloat(cut.normal.y) * sign * (3 + jitter)
                        )
                }
            }
        }
        .opacity(progress)
        .allowsHitTesting(false)
    }

    private func sidewallPath(points: [Vec2], center: CGPoint, radius: CGFloat) -> Path {
        guard points.count >= 2 else { return Path() }
        let face = keepPositive ? -1.0 : 1.0
        var path = Path()
        path.move(to: DishSpace.toView(points[0], center: center, radius: radius))
        for point in points.dropFirst() {
            path.addLine(to: DishSpace.toView(point, center: center, radius: radius))
        }
        for index in points.indices.reversed() {
            let previous = points[max(0, index - 1)]
            let next = points[min(points.count - 1, index + 1)]
            let tangent = next - previous
            let length = max(tangent.length, 1e-6)
            let outward = Vec2(x: -tangent.y / length * face, y: tangent.x / length * face)
            let point = DishSpace.toView(points[index], center: center, radius: radius)
            path.addLine(to: CGPoint(
                x: point.x + CGFloat(outward.x) * 6,
                y: point.y - CGFloat(outward.y) * 6 + 3
            ))
        }
        path.closeSubpath()
        return path
    }
}

private struct CheeseStretchView: View {
    var cut: Cut
    var progress: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side * 0.42
            let separation = radius * CGFloat(progress) * 0.14

            if cut.pathPoints.count >= 2 {
                ForEach([0.28, 0.50, 0.72], id: \.self) { fraction in
                    let point = cut.point(along: fraction)
                    let base = DishSpace.toView(point, center: center, radius: radius)
                    let dx = CGFloat(cut.normal.x) * separation
                    let dy = CGFloat(-cut.normal.y) * separation
                    Path { path in
                        path.move(to: CGPoint(x: base.x - dx, y: base.y - dy))
                        path.addQuadCurve(
                            to: CGPoint(x: base.x + dx, y: base.y + dy),
                            control: CGPoint(x: base.x + CGFloat(fraction - 0.5) * 14, y: base.y + 9)
                        )
                    }
                    .stroke(
                        LinearGradient(colors: [.white, Palette.gold, .white], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .shadow(color: Palette.gold.opacity(0.5), radius: 3)
                }
            }
        }
        .opacity(max(0, min(1, (0.82 - progress) * 2.5)))
        .allowsHitTesting(false)
    }
}

struct HintCutOverlay: View {
    var cut: Cut
    var center: CGPoint
    var radius: CGFloat
    var start: Date
    var reduceMotion: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(start))
            let cycle = elapsed.truncatingRemainder(dividingBy: 3.6) / 3.6
            let amount = reduceMotion ? 1 : min(max((cycle - 0.05) / 0.62, 0), 1)
            let points = cut.pathPoints.map { DishSpace.toView($0, center: center, radius: radius) }
            let path = Path { p in
                guard let first = points.first else { return }
                p.move(to: first)
                for point in points.dropFirst() { p.addLine(to: point) }
            }
            ZStack {
                path
                    .stroke(
                        Palette.gold.opacity(0.85),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 11])
                    )

                path.trimmedPath(from: 0, to: amount)
                    .stroke(.white.opacity(0.90), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                path.trimmedPath(from: 0, to: amount)
                    .stroke(Palette.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .shadow(color: Palette.gold.opacity(0.8), radius: 8)

                if !reduceMotion && amount > 0.02 {
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: Palette.ink.opacity(0.8), radius: 3, y: 2)
                        .position(DishSpace.toView(cut.point(along: min(max(amount, 0.15), 0.85)), center: center, radius: radius))
                }
            }
            .mask {
                Circle()
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct SwipeTrailOverlay: View {
    var points: [CGPoint]
    var center: CGPoint
    var radius: CGFloat
    var valid: Bool

    var body: some View {
        ZStack {
            trail
                .stroke(.white.opacity(0.82), style: StrokeStyle(lineWidth: 14, lineCap: .round))
            trail
                .stroke(
                    LinearGradient(
                        colors: valid
                            ? [Palette.sky, Palette.gold, Palette.coral]
                            : [Palette.coral.opacity(0.65), Palette.coral],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .shadow(color: (valid ? Palette.gold : Palette.coral).opacity(0.65), radius: 8)

            Image(systemName: valid ? "sparkle" : "exclamationmark")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(valid ? Palette.moss : Palette.coral, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 2))
                .position(points.last ?? center)
                .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
        }
        .mask {
            Circle()
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
        }
        .allowsHitTesting(false)
    }

    private var trail: Path {
        Path { p in
            guard let first = points.first else { return }
            p.move(to: first)
            for point in points.dropFirst() { p.addLine(to: point) }
        }
    }
}

struct SliceSparkBurst: View {
    var progress: Double
    var center: CGPoint
    var radius: CGFloat

    private let colors: [Color] = [Palette.gold, Palette.coral, Palette.sky, Palette.moss]

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) / 12 * 2 * Double.pi
                let distance = radius * CGFloat(0.2 + progress * 0.82)
                Image(systemName: index.isMultiple(of: 3) ? "sparkle" : "circle.fill")
                    .font(.system(size: index.isMultiple(of: 3) ? 18 : 9, weight: .heavy))
                    .foregroundStyle(colors[index % colors.count])
                    .position(center)
                    .offset(
                        x: CGFloat(cos(angle)) * distance,
                        y: CGFloat(sin(angle)) * distance
                    )
                    .rotationEffect(.radians(angle + progress * 2.4))
                    .scaleEffect(CGFloat(1 - progress * 0.35))
                    .opacity(1 - progress)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct SliceImpactOverlay: View {
    var cut: Cut
    var progress: Double
    var center: CGPoint
    var radius: CGFloat

    var body: some View {
        ZStack {
            let points = cut.pathPoints.map {
                DishSpace.toView($0, center: center, radius: radius)
            }
            if let first = points.first, points.count >= 2 {
                let flash = Path { path in
                    path.move(to: first)
                    for point in points.dropFirst() { path.addLine(to: point) }
                }
                flash
                    .trim(
                        from: max(0, 0.5 - progress * 0.72),
                        to: min(1, 0.5 + progress * 0.72)
                    )
                    .stroke(.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .shadow(color: Palette.gold, radius: 14)
                    .opacity(min(1, progress * 8) * max(0, 1 - progress * 1.8))

                ForEach(0..<9, id: \.self) { index in
                    let along = Double(index + 1) / 10
                    let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
                    let origin = DishSpace.toView(cut.point(along: along), center: center, radius: radius)
                    Capsule()
                        .fill(index.isMultiple(of: 3) ? Palette.coral : Palette.gold)
                        .frame(width: 5, height: 12)
                        .position(origin)
                        .offset(
                            x: CGFloat(cut.normal.x) * radius * CGFloat(progress) * direction * 0.38,
                            y: -CGFloat(cut.normal.y) * radius * CGFloat(progress) * direction * 0.38
                                + CGFloat(progress * progress) * 34
                        )
                        .rotationEffect(.radians(Double(index) * 0.6 + progress * 4))
                        .opacity(max(0, 1 - progress))
                }
            }
        }
        .mask {
            Circle()
                .frame(width: radius * 2.35, height: radius * 2.35)
                .position(center)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
