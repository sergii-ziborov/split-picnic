import SwiftUI

struct ToppingSprite: View {
    var kind: ToppingKind

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            Canvas { ctx, size in
                let r = min(size.width, size.height) / 2
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                switch kind {
                case .pepperoni: pepperoni(&ctx, c, r)
                case .mushroom: mushroom(&ctx, c, r)
                case .olive: olive(&ctx, c, r)
                case .pepper: pepper(&ctx, c, r)
                case .basil: basil(&ctx, c, r)
                case .strawberry: strawberry(&ctx, c, r)
                case .blueberry: blueberry(&ctx, c, r)
                case .cherry: cherry(&ctx, c, r)
                }
            }
            .frame(width: s, height: s)
        }
    }

    private func pepperoni(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(Color(red: 0.72, green: 0.16, blue: 0.14)))
        ctx.fill(Path(ellipseIn: rect.insetBy(dx: r * 0.18, dy: r * 0.18)), with: .color(Color(red: 0.86, green: 0.28, blue: 0.22)))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - r * 0.18, y: c.y - r * 0.2, width: r * 0.28, height: r * 0.22)), with: .color(Color(red: 0.95, green: 0.55, blue: 0.38).opacity(0.7)))
    }

    private func mushroom(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        var cap = Path()
        cap.addEllipse(in: CGRect(x: c.x - r * 0.9, y: c.y - r * 0.85, width: r * 1.8, height: r * 1.25))
        ctx.fill(cap, with: .color(Color(red: 0.82, green: 0.68, blue: 0.48)))
        ctx.stroke(cap, with: .color(Color(red: 0.55, green: 0.40, blue: 0.24)), lineWidth: 1.2)
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - r * 0.32, y: c.y - r * 0.1, width: r * 0.64, height: r * 0.7)),
            with: .color(Color(red: 0.93, green: 0.86, blue: 0.70))
        )
    }

    private func olive(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        let outer = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r * 0.85, width: r * 2, height: r * 1.7))
        ctx.fill(outer, with: .color(Color(red: 0.12, green: 0.12, blue: 0.14)))
        let hole = Path(ellipseIn: CGRect(x: c.x - r * 0.38, y: c.y - r * 0.32, width: r * 0.76, height: r * 0.64))
        ctx.fill(hole, with: .color(Color(red: 0.92, green: 0.78, blue: 0.42)))
    }

    private func pepper(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        var path = Path()
        path.addArc(center: c, radius: r * 0.85, startAngle: .degrees(-50), endAngle: .degrees(140), clockwise: false)
        path.addArc(center: CGPoint(x: c.x, y: c.y + r * 0.15), radius: r * 0.55, startAngle: .degrees(140), endAngle: .degrees(-50), clockwise: true)
        path.closeSubpath()
        ctx.fill(path, with: .color(Color(red: 0.38, green: 0.72, blue: 0.28)))
        ctx.stroke(path, with: .color(Color(red: 0.18, green: 0.48, blue: 0.16)), lineWidth: 1)
    }

    private func basil(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        var leaf = Path()
        leaf.move(to: CGPoint(x: c.x, y: c.y - r))
        leaf.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + r, y: c.y))
        leaf.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - r, y: c.y))
        ctx.fill(leaf, with: .color(Color(red: 0.22, green: 0.62, blue: 0.28)))
        ctx.stroke(leaf, with: .color(Color(red: 0.12, green: 0.40, blue: 0.16)), lineWidth: 0.8)
    }

    private func strawberry(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        var body = Path()
        body.move(to: CGPoint(x: c.x, y: c.y + r))
        body.addQuadCurve(to: CGPoint(x: c.x - r * 0.9, y: c.y - r * 0.15), control: CGPoint(x: c.x - r, y: c.y + r * 0.4))
        body.addQuadCurve(to: CGPoint(x: c.x + r * 0.9, y: c.y - r * 0.15), control: CGPoint(x: c.x, y: c.y - r * 0.55))
        body.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + r, y: c.y + r * 0.4))
        ctx.fill(body, with: .color(Color(red: 0.90, green: 0.18, blue: 0.28)))
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - r * 0.45, y: c.y - r * 0.95, width: r * 0.9, height: r * 0.45)),
            with: .color(Color(red: 0.28, green: 0.62, blue: 0.28))
        )
    }

    private func blueberry(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
            with: .color(Color(red: 0.28, green: 0.28, blue: 0.72))
        )
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - r * 0.25, y: c.y - r * 0.45, width: r * 0.4, height: r * 0.28)),
            with: .color(.white.opacity(0.45))
        )
    }

    private func cherry(_ ctx: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat) {
        ctx.fill(
            Path(ellipseIn: CGRect(x: c.x - r * 0.9, y: c.y - r * 0.55, width: r * 1.8, height: r * 1.7)),
            with: .color(Color(red: 0.72, green: 0.08, blue: 0.16))
        )
        var stem = Path()
        stem.move(to: CGPoint(x: c.x, y: c.y - r * 0.4))
        stem.addQuadCurve(to: CGPoint(x: c.x + r * 0.35, y: c.y - r), control: CGPoint(x: c.x + r * 0.05, y: c.y - r * 0.7))
        ctx.stroke(stem, with: .color(Color(red: 0.22, green: 0.48, blue: 0.18)), lineWidth: 2)
    }
}

struct OrderIcons: View {
    var order: GuestOrder
    var language: AppLanguage

    var body: some View {
        HStack(spacing: 4) {
            if order.isRemainder {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Palette.moss)
            } else {
                ForEach(order.required, id: \.kind) { rule in
                    HStack(spacing: 1) {
                        ForEach(0..<min(rule.min, 3), id: \.self) { _ in
                            ToppingSprite(kind: rule.kind)
                                .frame(width: 22, height: 22)
                        }
                    }
                }
                ForEach(Array(order.forbidden), id: \.self) { kind in
                    ZStack {
                        ToppingSprite(kind: kind)
                            .frame(width: 22, height: 22)
                            .opacity(0.55)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(Palette.coral)
                    }
                }
            }
        }
    }
}
