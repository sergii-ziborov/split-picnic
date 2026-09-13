import SwiftUI

struct TutorialView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var page = 0
    @State private var clipStart = Date()

    var body: some View {
        let loc = model.loc
        let pages = [
            loc["drawLine"],
            loc["tutorial2"],
            loc["tutorial3"],
        ]
        GeometryReader { geo in
            let compact = geo.size.height < 800
            ZStack {
                PicnicBackdrop(asset: "PicnicBackground")
                VStack(spacing: compact ? 8 : 12) {
                    HStack {
                        CircleIconButton(system: "chevron.left") {
                            if page == 0 { model.closeTutorial() } else { changePage(to: page - 1) }
                        }
                        .accessibilityIdentifier("tutorial-back")
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    Text(loc["howToPlay"])
                        .font(.spDisplay(compact ? 24 : 30))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(page + 1)/3")
                        .font(.spBody(13))
                        .foregroundStyle(Palette.inkSoft)

                    HStack(alignment: .bottom) {
                        GuestPortrait(guest: .dog, happy: true, size: compact ? 72 : 100)
                        Spacer()
                        GuestPortrait(guest: .cat, happy: true, size: compact ? 72 : 100)
                    }
                    .padding(.horizontal, 16)

                    Group {
                        if page < 2 {
                            TutorialClip(
                                page: page,
                                start: clipStart,
                                reduceMotion: systemReduceMotion || model.progress.reduceMotion,
                                accessibilityText: page == 0 ? loc["cutTutorialClip"] : loc["servingTutorialClip"]
                            )
                            .accessibilityIdentifier(page == 0 ? "tutorial-cut-clip" : "tutorial-serving-clip")
                            .overlay(alignment: .topTrailing) {
                                if !(systemReduceMotion || model.progress.reduceMotion) {
                                    Button { clipStart = Date() } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundStyle(Palette.ink)
                                            .frame(width: 38, height: 38)
                                            .background(.white.opacity(0.94), in: Circle())
                                    }
                                    .accessibilityLabel(loc["replayTutorialClip"])
                                    .accessibilityIdentifier("tutorial-replay")
                                    .padding(10)
                                }
                            }
                        } else {
                            DishCanvas(kind: .pizza, toppings: TutorialDemo.toppings, cut: TutorialDemo.cut, split: 0)
                        }
                    }
                    .frame(height: compact ? 170 : 220)
                    .frame(maxWidth: 340)
                    .frame(maxWidth: .infinity)

                    Text(pages[page])
                        .font(.spBody(compact ? 15 : 17))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: 360)
                        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)

                    SPButton(
                        title: page == 2 ? (model.tutorialReturnScreen != nil ? loc["done"] : loc["startPicnic"]) : loc["next"],
                        kind: .play,
                        icon: page == 2 ? (model.tutorialReturnScreen != nil ? "checkmark" : "play.fill") : "arrow.right"
                    ) {
                        if page == 2 {
                            if model.tutorialReturnScreen != nil { model.closeTutorial() } else { model.finishTutorial() }
                        } else {
                            changePage(to: page + 1)
                        }
                    }
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("tutorial-next")

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i == page ? Palette.moss : Palette.creamDark)
                                .frame(width: 8, height: 8)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func changePage(to newPage: Int) {
        page = newPage
        clipStart = Date()
    }
}

private enum TutorialDemo {
    static let cut = Cut.following([
        Vec2(x: 0, y: 1),
        Vec2(x: 0.03, y: 0.79),
        Vec2(x: 0.13, y: 0.50),
        Vec2(x: 0.22, y: 0.13),
        Vec2(x: 0.16, y: -0.20),
        Vec2(x: 0.05, y: -0.53),
        Vec2(x: 0, y: -1),
    ])!

    static let toppings: [Topping] = [
        Topping(id: 0, kind: .pepperoni, position: Vec2(x: -0.43, y: 0.35), radius: 0.085),
        Topping(id: 1, kind: .pepperoni, position: Vec2(x: -0.49, y: -0.04), radius: 0.085),
        Topping(id: 2, kind: .pepperoni, position: Vec2(x: -0.35, y: -0.45), radius: 0.085),
        Topping(id: 3, kind: .mushroom, position: Vec2(x: 0.48, y: 0.40), radius: 0.08),
        Topping(id: 4, kind: .mushroom, position: Vec2(x: 0.53, y: -0.03), radius: 0.08),
        Topping(id: 5, kind: .mushroom, position: Vec2(x: 0.39, y: -0.48), radius: 0.08),
    ]
}

private struct TutorialClip: View {
    var page: Int
    var start: Date
    var reduceMotion: Bool
    var accessibilityText: String

    private let duration = 4.6

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(start))
            let fraction = reduceMotion ? 0.88 : elapsed.truncatingRemainder(dividingBy: duration) / duration
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.38))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.62), lineWidth: 1.5)
                    }

                if page == 0 {
                    TutorialCutClip(fraction: fraction)
                } else {
                    TutorialServingClip(fraction: fraction)
                }

                GeometryReader { geo in
                    Capsule()
                        .fill(Palette.ink.opacity(0.15))
                        .frame(width: geo.size.width - 44, height: 4)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Palette.moss)
                                .frame(width: (geo.size.width - 44) * fraction, height: 4)
                        }
                        .position(x: geo.size.width / 2, y: geo.size.height - 12)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }
}

private struct TutorialCutClip: View {
    var fraction: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.height * 0.91, geo.size.width * 0.62)
            let center = CGPoint(x: geo.size.width / 2, y: (geo.size.height - 12) / 2)
            let draw = min(max((fraction - 0.06) / 0.45, 0), 1)
            let split = smooth((fraction - 0.56) / 0.23)

            ZStack {
                if split > 0 {
                    SplitDishView(
                        kind: .pizza,
                        toppings: TutorialDemo.toppings,
                        cut: TutorialDemo.cut,
                        progress: split,
                        plate: .paw
                    )
                    .frame(width: side, height: side)
                    .position(center)
                } else {
                    DishCanvas(kind: .pizza, toppings: TutorialDemo.toppings, cut: TutorialDemo.cut, split: 0)
                        .frame(width: side, height: side)
                        .position(center)
                }

                if draw > 0 && split < 0.45 {
                    let path = TutorialDemo.cut.pathPoints.map {
                        DishSpace.toView($0, center: center, radius: side * 0.42)
                    }
                    SwipeTrailOverlay(
                        points: partialPath(path, fraction: draw),
                        center: center,
                        radius: side * 0.47,
                        valid: true
                    )
                    .opacity(1 - split * 2.2)
                }

                if split > 0 && split < 0.85 {
                    SliceSparkBurst(progress: split, center: center, radius: side * 0.43)
                        .opacity(1 - split)
                }
            }
        }
    }
}

private struct TutorialServingClip: View {
    var fraction: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.height * 0.82, geo.size.width * 0.49)
            let plateSide = min(geo.size.height * 0.47, geo.size.width * 0.27)
            let centerX = geo.size.width / 2
            let startY = geo.size.height * 0.39
            let plateY = geo.size.height * 0.63
            let leftX = geo.size.width * 0.22
            let rightX = geo.size.width * 0.78
            let travel = smooth((fraction - 0.13) / 0.56)
            let arrival = smooth((fraction - 0.67) / 0.16)

            ZStack {
                PlateView(plate: .paw)
                    .frame(width: plateSide, height: plateSide)
                    .position(x: leftX, y: plateY)
                PlateView(plate: .heart)
                    .frame(width: plateSide, height: plateSide)
                    .position(x: rightX, y: plateY)

                half(positive: false, side: side)
                    .scaleEffect(1 - travel * 0.36)
                    .rotationEffect(.degrees(-travel * 7))
                    .position(x: centerX + (leftX - centerX) * travel, y: startY + (plateY - startY) * travel)

                half(positive: true, side: side)
                    .scaleEffect(1 - travel * 0.36)
                    .rotationEffect(.degrees(travel * 7))
                    .position(x: centerX + (rightX - centerX) * travel, y: startY + (plateY - startY) * travel)

                checkmark(at: CGPoint(x: leftX, y: plateY - plateSide * 0.53), arrival: arrival)
                checkmark(at: CGPoint(x: rightX, y: plateY - plateSide * 0.53), arrival: arrival)
            }
        }
    }

    private func half(positive: Bool, side: CGFloat) -> some View {
        DishCanvas(
            kind: .pizza,
            toppings: TutorialDemo.toppings.filter {
                TutorialDemo.cut.half(of: $0.position) == (positive ? .positive : .negative)
            },
            cut: TutorialDemo.cut,
            split: 0,
            showBoard: false
        )
        .frame(width: side, height: side)
        .clipShape(HalfDishShape(cut: TutorialDemo.cut, keepPositive: positive))
        .shadow(color: .black.opacity(0.22), radius: 6, y: 5)
    }

    private func checkmark(at point: CGPoint, arrival: Double) -> some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 27, weight: .bold))
            .foregroundStyle(Palette.moss)
            .background(.white, in: Circle())
            .scaleEffect(0.55 + arrival * 0.45)
            .opacity(arrival)
            .position(point)
    }
}

private func smooth(_ value: Double) -> Double {
    let t = min(max(value, 0), 1)
    return t * t * (3 - 2 * t)
}

private func partialPath(_ points: [CGPoint], fraction: Double) -> [CGPoint] {
    guard let first = points.first else { return [] }
    guard points.count > 1 else { return [first] }
    let progress = min(max(fraction, 0), 1) * Double(points.count - 1)
    let segment = min(Int(progress), points.count - 2)
    let local = progress - Double(segment)
    let a = points[segment]
    let b = points[segment + 1]
    return Array(points.prefix(segment + 1)) + [
        CGPoint(x: a.x + (b.x - a.x) * local, y: a.y + (b.y - a.y) * local)
    ]
}
