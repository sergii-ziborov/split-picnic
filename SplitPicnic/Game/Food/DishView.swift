import SwiftUI

struct HalfDishShape: Shape {
    var cut: Cut
    var keepPositive: Bool

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var pts: [CGPoint] = []
        let samples = 96
        for i in 0..<samples {
            let a = Double(i) / Double(samples) * 2 * .pi
            let p = Vec2(x: cos(a), y: sin(a))
            let d = cut.signedDistance(p)
            let keep = keepPositive ? d >= -1e-6 : d <= 1e-6
            if keep {
                pts.append(DishSpace.toView(p, center: center, radius: radius))
            }
        }
        guard pts.count >= 2 else {
            if keepPositive == (cut.offset < 0) {
                return Path(ellipseIn: rect)
            }
            return Path()
        }
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
    var hideToppings: Bool = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let board = side * 0.50
            let food = side * 0.42

            ZStack {
                boardLayer(radius: board)
                foodLayer(radius: food)
                if !hideToppings {
                    toppingsLayer(center: center, radius: food)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
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
            .overlay(Circle().stroke(Color(red: 0.40, green: 0.24, blue: 0.12), lineWidth: 6))
            .frame(width: radius * 2, height: radius * 2)
            .shadow(color: .black.opacity(0.28), radius: 14, y: 8)
    }

    @ViewBuilder
    private func foodLayer(radius: CGFloat) -> some View {
        let size = radius * 2
        Canvas { ctx, canvasSize in
            let r = min(canvasSize.width, canvasSize.height) / 2
            let c = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            if kind == .pizza {
                drawPizza(ctx: &ctx, center: c, r: r)
            } else {
                drawPie(ctx: &ctx, center: c, r: r)
            }
        }
        .frame(width: size, height: size)
    }

    private func toppingsLayer(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(toppings) { topping in
            let p = DishSpace.toView(topping.position, center: center, radius: radius)
            ToppingSprite(kind: topping.kind)
                .frame(width: CGFloat(topping.radius) * radius * 2.4, height: CGFloat(topping.radius) * radius * 2.4)
                .position(p)
        }
    }

    private func drawPizza(ctx: inout GraphicsContext, center: CGPoint, r: CGFloat) {
        let crust = Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.fill(
            crust,
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.93, green: 0.74, blue: 0.38),
                    Color(red: 0.78, green: 0.48, blue: 0.18),
                ]),
                center: center,
                startRadius: r * 0.2,
                endRadius: r
            )
        )
        let sauceR = r * 0.84
        let sauce = Path(ellipseIn: CGRect(x: center.x - sauceR, y: center.y - sauceR, width: sauceR * 2, height: sauceR * 2))
        ctx.fill(sauce, with: .color(Color(red: 0.78, green: 0.18, blue: 0.14)))
        let cheeseR = r * 0.80
        let cheese = Path(ellipseIn: CGRect(x: center.x - cheeseR, y: center.y - cheeseR, width: cheeseR * 2, height: cheeseR * 2))
        ctx.fill(cheese, with: .color(Color(red: 0.98, green: 0.86, blue: 0.48).opacity(0.95)))
        for i in 0..<18 {
            let a = Double(i) * 0.7
            let rr = cheeseR * (0.15 + CGFloat((i * 37) % 70) / 120)
            let p = CGPoint(x: center.x + cos(a) * rr, y: center.y + sin(a) * rr)
            let blob = Path(ellipseIn: CGRect(x: p.x - 10, y: p.y - 8, width: 22, height: 16))
            ctx.fill(blob, with: .color(Color(red: 1.0, green: 0.93, blue: 0.62).opacity(0.55)))
        }
        ctx.stroke(crust, with: .color(Color(red: 0.62, green: 0.34, blue: 0.12).opacity(0.5)), lineWidth: 3)
    }

    private func drawPie(ctx: inout GraphicsContext, center: CGPoint, r: CGFloat) {
        let crust = Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        ctx.fill(
            crust,
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.94, green: 0.80, blue: 0.52),
                    Color(red: 0.72, green: 0.46, blue: 0.20),
                ]),
                center: center,
                startRadius: r * 0.2,
                endRadius: r
            )
        )
        let fillR = r * 0.82
        let fill = Path(ellipseIn: CGRect(x: center.x - fillR, y: center.y - fillR, width: fillR * 2, height: fillR * 2))
        ctx.fill(
            fill,
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.98, green: 0.94, blue: 0.82),
                    Color(red: 0.92, green: 0.72, blue: 0.42),
                ]),
                center: center,
                startRadius: 4,
                endRadius: fillR
            )
        )
        ctx.stroke(crust, with: .color(Color(red: 0.55, green: 0.32, blue: 0.12).opacity(0.45)), lineWidth: 3)
    }
}

struct SplitDishView: View {
    var kind: DishKind
    var toppings: [Topping]
    var cut: Cut
    var progress: Double
    var plate: PlateID

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let foodR = side * 0.42
            let amount = progress * foodR * 0.42
            ZStack {
                half(keepPositive: true, amount: amount, in: geo.size)
                half(keepPositive: false, amount: amount, in: geo.size)
            }
        }
    }

    private func half(keepPositive: Bool, amount: CGFloat, in size: CGSize) -> some View {
        let half: Half = keepPositive ? .positive : .negative
        let slide = SliceGeometry.slideOffset(cut: cut, half: half, amount: Double(amount) / 200)
        // slide is in unit space; convert roughly
        let px = CGFloat(slide.x) * (size.width * 0.42)
        let py = CGFloat(-slide.y) * (size.height * 0.42)
        return DishCanvas(kind: kind, toppings: toppings.filter { cut.half(of: $0.position) == half }, cut: cut, split: 0)
            .clipShape(HalfDishShape(cut: cut, keepPositive: keepPositive))
            .offset(x: px, y: py)
    }
}

struct CutOverlay: View {
    var cut: Cut
    var hint: Cut?
    var showHint: Bool
    var handles: Bool
    var center: CGPoint
    var radius: CGFloat

    var body: some View {
        ZStack {
            if showHint, let hint, let chord = hint.chord() {
                dashed(from: DishSpace.toView(chord.0, center: center, radius: radius),
                       to: DishSpace.toView(chord.1, center: center, radius: radius),
                       color: Palette.gold.opacity(0.85))
            }
            if let chord = cut.chord() {
                let a = DishSpace.toView(chord.0, center: center, radius: radius)
                let b = DishSpace.toView(chord.1, center: center, radius: radius)
                Path { p in
                    p.move(to: a)
                    p.addLine(to: b)
                }
                .stroke(Palette.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 8]))
                .shadow(color: Palette.gold.opacity(0.6), radius: 6)

                if handles {
                    handle(at: a)
                    handle(at: b)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func dashed(from a: CGPoint, to b: CGPoint, color: Color) -> some View {
        Path { p in
            p.move(to: a)
            p.addLine(to: b)
        }
        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 8]))
    }

    private func handle(at p: CGPoint) -> some View {
        Circle()
            .fill(.white)
            .overlay(Circle().stroke(Palette.gold, lineWidth: 3))
            .frame(width: 22, height: 22)
            .position(p)
            .shadow(color: .black.opacity(0.2), radius: 3)
    }
}
