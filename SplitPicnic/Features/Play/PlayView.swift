import SwiftUI

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @State private var showPause = false
    @State private var splitProgress: Double = 0
    @State private var dragStart: CGPoint?
    @State private var activeHandle: Handle?
    @State private var dishFrame: CGRect = .zero

    private enum Handle { case a, b, body }

    var body: some View {
        if let session = model.session {
            content(session)
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
        let cloth = session.context.theme.cloth
        return ZStack {
            PicnicBackdrop(asset: session.context.world.backgroundAsset, dim: 0.08)
            Gingham(color: Color(red: cloth.red, green: cloth.green, blue: cloth.blue), cell: 22)
                .opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                hud(session, loc: loc)
                guests(session)
                dish(session)
                    .frame(maxHeight: .infinity)
                bottom(session, loc: loc)
            }
            .padding(.bottom, 16)

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
                Text("Level \(session.level.number)")
                    .font(.spBody(14))
                    .foregroundStyle(Palette.ink)
                StarRow(stars: model.progress.stars(for: session.level), size: 14)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white.opacity(0.92), in: Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            Spacer()
            Button {
                model.useHint()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(session.hintsLeft > 0 ? Palette.gold : Palette.ink.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.92), in: Circle())
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    if session.hintsLeft > 0 {
                        Text("\(session.hintsLeft)")
                            .font(.spBody(10))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Palette.coral, in: Circle())
                            .offset(x: 6, y: -4)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(session.hintsLeft == 0 || session.phase != .aiming)
            .accessibilityIdentifier("hint-button")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func guests(_ session: PlaySession) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(spacing: 6) {
                GuestOrderCard(
                    guest: .dog,
                    order: session.level.dog,
                    language: model.progress.language,
                    happy: session.lastSlice.map(\.dogHappy),
                    compact: true
                )
                GuestPortrait(guest: .dog, happy: session.lastSlice?.dogHappy ?? true, size: 108)
            }
            Spacer(minLength: 0)
            VStack(spacing: 6) {
                GuestOrderCard(
                    guest: .cat,
                    order: session.level.cat,
                    language: model.progress.language,
                    happy: session.lastSlice.map(\.catHappy),
                    compact: true
                )
                GuestPortrait(guest: .cat, happy: session.lastSlice?.catHappy ?? true, size: 108)
            }
        }
        .padding(.horizontal, 12)
    }

    private func dish(_ session: PlaySession) -> some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side * 0.42

            ZStack {
                if session.phase == .slicing || session.phase == .resolved, let cut = session.draft {
                    SplitDishView(
                        kind: session.level.dish,
                        toppings: session.toppings,
                        cut: cut,
                        progress: splitProgress,
                        plate: session.context.plate
                    )
                } else {
                    DishCanvas(kind: session.level.dish, toppings: session.toppings, cut: session.draft, split: 0)
                }

                if session.phase == .aiming {
                    CutOverlay(
                        cut: session.draft ?? session.level.hint,
                        hint: session.level.hint,
                        showHint: session.showHint,
                        handles: session.draft != nil,
                        center: center,
                        radius: radius
                    )
                    .opacity(session.draft == nil && !session.showHint ? 0 : 1)
                }
            }
            .contentShape(Rectangle())
            .gesture(dishGesture(session: session, center: center, radius: radius))
            .onAppear { dishFrame = geo.frame(in: .local) }
            .accessibilityIdentifier("dish")
        }
        .padding(.horizontal, 8)
    }

    private func bottom(_ session: PlaySession, loc: L10n) -> some View {
        VStack(spacing: 8) {
            if session.level.minAreaRatio != nil {
                Text(loc["fair"])
                    .font(.spBody(13))
                    .foregroundStyle(Palette.inkSoft)
            } else {
                Text(loc["adjust"])
                    .font(.spBody(13))
                    .foregroundStyle(Palette.inkSoft)
            }
            SPButton(title: loc["slice"], kind: .play, icon: "checkmark") {
                model.confirmSlice()
            }
            .disabled(session.draft == nil || session.phase != .aiming)
            .opacity(session.draft == nil ? 0.5 : 1)
            .padding(.horizontal, 28)
            .accessibilityIdentifier("slice-button")
        }
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
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard session.phase == .aiming else { return }
                if dragStart == nil {
                    dragStart = value.startLocation
                    activeHandle = nearestHandle(at: value.startLocation, cut: session.draft, center: center, radius: radius)
                }
                guard let start = dragStart else { return }
                let p1 = DishSpace.fromView(start, center: center, radius: radius)
                let p2 = DishSpace.fromView(value.location, center: center, radius: radius)

                if let handle = activeHandle, let current = session.draft, let chord = current.chord() {
                    switch handle {
                    case .a:
                        session.draft = Cut.through(p2, chord.1) ?? current
                    case .b:
                        session.draft = Cut.through(chord.0, p2) ?? current
                    case .body:
                        let delta = current.normal.x * (p2.x - p1.x) + current.normal.y * (p2.y - p1.y)
                        session.draft = current.translating(by: delta)
                        dragStart = value.location
                    }
                } else if let cut = Cut.through(p1, p2), abs(cut.offset) < 0.95 {
                    session.draft = cut
                }
            }
            .onEnded { _ in
                dragStart = nil
                activeHandle = nil
                if model.progress.hapticsEnabled { Feedback.tap() }
            }
    }

    private func nearestHandle(at point: CGPoint, cut: Cut?, center: CGPoint, radius: CGFloat) -> Handle? {
        guard let cut, let chord = cut.chord() else { return nil }
        let a = DishSpace.toView(chord.0, center: center, radius: radius)
        let b = DishSpace.toView(chord.1, center: center, radius: radius)
        let da = hypot(point.x - a.x, point.y - a.y)
        let db = hypot(point.x - b.x, point.y - b.y)
        if da < 28 { return .a }
        if db < 28 { return .b }
        // Distance to segment
        let dist = distanceToSegment(point, a, b)
        if dist < 22 { return .body }
        return nil
    }

    private func distanceToSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let len2 = dx * dx + dy * dy
        guard len2 > 1 else { return hypot(p.x - a.x, p.y - a.y) }
        var t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2
        t = min(max(t, 0), 1)
        let x = a.x + t * dx
        let y = a.y + t * dy
        return hypot(p.x - x, p.y - y)
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
