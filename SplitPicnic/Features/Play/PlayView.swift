import SwiftUI

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var showPause = false
    @State private var splitProgress: Double = 0
    @State private var swipePoints: [CGPoint] = []
    @State private var hintStart = Date()

    var body: some View {
        if let session = model.session {
            content(session)
                .onAppear {
                    if session.phase == .resolved, session.draft != nil {
                        splitProgress = 1
                    }
                }
                .onChange(of: session.phase) { _, phase in
                    if phase == .slicing {
                        animateSlice()
                    }
                }
        } else {
            Palette.cream.onAppear { model.goHome() }
        }
    }

    private func content(_ session: PlaySession) -> some View {
        let loc = model.loc
        return ZStack {
            PicnicBackdrop(asset: session.context.world.backgroundAsset, dim: 0.12)
                .overlay {
                    LinearGradient(
                        colors: [
                            themeColor(session.context.theme).opacity(0.12),
                            .clear,
                            themeColor(session.context.theme).opacity(0.16),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                .allowsHitTesting(false)
            VStack(spacing: 6) {
                hud(session, loc: loc)
                guests(session, size: 72, compact: true)
                dish(session)
                    .frame(maxHeight: .infinity)
                bottom(session, loc: loc)
            }
            .padding(.bottom, 8)

            if showPause {
                pauseOverlay(loc: loc)
            }
        }
    }

    private func hud(_ session: PlaySession, loc: L10n) -> some View {
        HStack {
            CircleIconButton(system: "pause.fill") { showPause = true }
                .accessibilityIdentifier("pause-button")
            Spacer()
            VStack(spacing: 2) {
                Text("\(loc["level"]) \(session.level.number)")
                    .font(.spBody(14))
                    .foregroundStyle(Palette.ink)
                HStack(spacing: 8) {
                    StarRow(stars: model.progress.stars(for: session.level), size: 12)
                    difficultyDots(session.level.difficulty)
                }
                HStack(spacing: 4) {
                    Circle()
                        .fill(themeColor(session.context.theme))
                        .frame(width: 7, height: 7)
                    Text(session.context.theme.title)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white.opacity(0.92), in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            Spacer()
            Button {
                if session.showHint {
                    Feedback.tap(sound: model.progress.soundEnabled, haptics: model.progress.hapticsEnabled)
                } else {
                    model.useHint()
                }
                hintStart = Date()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: session.showHint ? "arrow.clockwise" : "lightbulb.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(session.showHint ? Palette.moss : session.hintsLeft > 0 ? Palette.gold : Palette.ink.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.92), in: Circle())
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    if session.hintsLeft > 0 && !session.showHint {
                        Text("\(session.hintsLeft)")
                            .font(.spBody(10))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Palette.coral, in: Circle())
                            .offset(x: 4, y: -2)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled((session.hintsLeft == 0 && !session.showHint) || session.phase != .aiming)
            .accessibilityLabel(session.showHint ? loc["replayHint"] : loc["showHint"])
            .accessibilityIdentifier("hint-button")
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private func guests(_ session: PlaySession, size: CGFloat, compact: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            guestColumn(
                .dog,
                order: session.level.dog,
                happy: session.lastSlice?.dogHappy,
                size: size,
                compact: compact,
                variant: session.context.guestVariant(for: .dog)
            )
            guestColumn(
                .cat,
                order: session.level.cat,
                happy: session.lastSlice?.catHappy,
                size: size,
                compact: compact,
                variant: session.context.guestVariant(for: .cat)
            )
        }
        .padding(.horizontal, 10)
    }

    private func guestColumn(
        _ guest: GuestID,
        order: GuestOrder,
        happy: Bool?,
        size: CGFloat,
        compact: Bool,
        variant: GuestVariant
    ) -> some View {
        VStack(spacing: 4) {
            GuestOrderCard(
                guest: guest,
                order: order,
                language: model.progress.language,
                happy: happy,
                compact: compact
            )
            GuestPortrait(guest: guest, happy: happy ?? true, size: size, variant: variant)
        }
        .frame(maxWidth: .infinity)
    }

    private func dish(_ session: PlaySession) -> some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side * 0.42

            ZStack {
                picnicCloth(theme: session.context.theme, side: side)

                if session.phase == .slicing || session.phase == .resolved, let cut = session.draft {
                    SplitDishView(
                        kind: session.level.dish,
                        toppings: session.toppings,
                        cut: cut,
                        progress: splitProgress,
                        plate: session.context.plate,
                        pizzaBaseAsset: session.context.pizzaBaseAsset
                    )
                    if session.phase == .slicing {
                        SliceImpactOverlay(
                            cut: cut,
                            progress: splitProgress,
                            center: center,
                            radius: radius
                        )
                        SliceSparkBurst(progress: splitProgress, center: center, radius: radius)
                    }
                } else {
                    DishCanvas(
                        kind: session.level.dish,
                        toppings: session.toppings,
                        cut: session.draft,
                        split: 0,
                        pizzaBaseAsset: session.context.pizzaBaseAsset
                    )
                }

                if session.phase == .aiming {
                    if session.showHint {
                        HintCutOverlay(
                            cut: session.level.hint,
                            center: center,
                            radius: radius,
                            start: hintStart,
                            reduceMotion: systemReduceMotion || model.progress.reduceMotion
                        )
                            .transition(.opacity.combined(with: .scale(scale: 0.94)))
                    }
                    if swipePoints.count >= 2 {
                        SwipeTrailOverlay(
                            points: swipePoints,
                            center: center,
                            radius: radius,
                            valid: swipeIsValid(
                                session: session,
                                points: swipePoints,
                                center: center,
                                radius: radius
                            )
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(dishGesture(session: session, center: center, radius: radius))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.loc["swipeToSlice"])
            .accessibilityIdentifier("dish")
        }
        .padding(.horizontal, 8)
    }

    private func picnicCloth(theme: ThemeID, side: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
        return Gingham(color: themeColor(theme), cell: 24)
            .overlay(themeColor(theme).opacity(0.09))
            .clipShape(shape)
            .overlay(shape.stroke(.white.opacity(0.88), lineWidth: 3))
            .frame(width: side * 1.08, height: side * 1.04)
            .rotationEffect(.degrees(-4))
            .shadow(color: .black.opacity(0.22), radius: 12, y: 7)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func bottom(_ session: PlaySession, loc: L10n) -> some View {
        VStack(spacing: 6) {
            if session.level.minAreaRatio != nil || session.level.requiresCleanCut {
                HStack(spacing: 6) {
                    if session.level.minAreaRatio != nil {
                        challengeBadge(
                            title: loc["fairChallenge"],
                            system: "circle.lefthalf.filled",
                            color: Palette.sky
                        )
                    }
                    if session.level.requiresCleanCut {
                        challengeBadge(
                            title: loc["cleanChallenge"],
                            system: "sparkles",
                            color: Palette.coral
                        )
                    }
                }
            }

            if session.showHint {
                HStack(spacing: 9) {
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Palette.gold)
                    Text(loc["hintGuide"])
                        .font(.spBody(12))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .accessibilityIdentifier("hint-guide-text")
                    Spacer(minLength: 0)
                    Button {
                        model.openTutorial(from: .play)
                    } label: {
                        Label(loc["watchTutorial"], systemImage: "play.rectangle.fill")
                            .font(.spBody(12))
                            .foregroundStyle(Palette.moss)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hint-demo-button")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Palette.gold.opacity(0.8), lineWidth: 2))
                .shadow(color: .black.opacity(0.12), radius: 7, y: 3)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(themeColor(session.context.theme))
                    Text(loc["swipeToSlice"])
                        .font(.spBody(15))
                        .foregroundStyle(Palette.ink)
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Palette.sky)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.white.opacity(0.92), in: Capsule())
                .overlay(Capsule().stroke(themeColor(session.context.theme).opacity(0.75), lineWidth: 2))
                .shadow(color: .black.opacity(0.12), radius: 7, y: 3)
                .accessibilityIdentifier("swipe-prompt")
            }
        }
        .padding(.horizontal, 16)
        .opacity(session.phase == .aiming ? 1 : 0)
        .allowsHitTesting(session.phase == .aiming)
    }

    private func challengeBadge(title: String, system: String, color: Color) -> some View {
        Label(title, systemImage: system)
            .font(.spBody(11))
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.92), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.8), lineWidth: 1.5))
    }

    private func pauseOverlay(loc: L10n) -> some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            WoodPanel {
                VStack(spacing: 12) {
                    Text(loc["pause"])
                        .font(.spDisplay(26))
                        .foregroundStyle(Palette.ink)
                    SPButton(title: loc["resume"], kind: .play) { showPause = false }
                    SPButton(title: loc["home"], kind: .quiet, icon: "house.fill") {
                        showPause = false
                        model.goHome()
                    }
                }
                .frame(maxWidth: 280)
            }
        }
    }

    private func dishGesture(session: PlaySession, center: CGPoint, radius: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard session.phase == .aiming else { return }
                if swipePoints.isEmpty {
                    Feedback.swipe(
                        sound: model.progress.soundEnabled,
                        haptics: model.progress.hapticsEnabled
                    )
                    swipePoints = [value.startLocation]
                }
                appendSwipePoint(value.location)
            }
            .onEnded { value in
                guard session.phase == .aiming else {
                    clearSwipe()
                    return
                }
                appendSwipePoint(value.location)
                let completedPoints = swipePoints
                let cut = SwipeGeometry.cut(
                    from: completedPoints,
                    center: center,
                    radius: radius
                )
                clearSwipe()
                guard let cut else {
                    Feedback.tap(
                        sound: model.progress.soundEnabled,
                        haptics: model.progress.hapticsEnabled
                    )
                    return
                }
                model.slice(with: cut)
            }
    }

    private func difficultyDots(_ difficulty: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < difficulty ? difficultyColor(difficulty) : Palette.creamDark)
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityLabel("\(model.loc["difficulty"]) \(difficulty) / 5")
    }

    private func difficultyColor(_ difficulty: Int) -> Color {
        switch difficulty {
        case 1: Palette.moss
        case 2: Palette.sky
        case 3: Palette.gold
        case 4: Palette.coral
        default: Color(red: 0.64, green: 0.32, blue: 0.82)
        }
    }

    private func themeColor(_ theme: ThemeID) -> Color {
        let cloth = theme.cloth
        return Color(red: cloth.red, green: cloth.green, blue: cloth.blue)
    }

    private func swipeIsValid(
        session: PlaySession,
        points: [CGPoint],
        center: CGPoint,
        radius: CGFloat
    ) -> Bool {
        guard session.level.requiresCleanCut else { return true }
        return session.toppings.allSatisfy { topping in
            SwipeGeometry.minimumDistance(
                from: topping.position,
                toViewPoints: points,
                center: center,
                radius: radius
            ) > topping.radius * 1.55
        }
    }

    private func appendSwipePoint(_ point: CGPoint) {
        guard let last = swipePoints.last else {
            swipePoints = [point]
            return
        }
        if hypot(point.x - last.x, point.y - last.y) >= 2 {
            swipePoints.append(point)
        }
    }

    private func clearSwipe() {
        swipePoints.removeAll(keepingCapacity: true)
    }

    private func animateSlice() {
        splitProgress = 0
        withAnimation(.easeOut(duration: 0.55)) {
            splitProgress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if model.session?.phase == .slicing {
                model.finishSlice()
            }
        }
    }
}
