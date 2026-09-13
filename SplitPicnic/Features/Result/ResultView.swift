import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let loc = model.loc
        if let outcome = model.lastOutcome {
            GeometryReader { geo in
                let compact = geo.size.height < 800
                ZStack {
                    PicnicBackdrop(asset: outcome.world.backgroundAsset)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: compact ? 10 : 14) {
                            HStack {
                                CircleIconButton(system: "house.fill") { model.goHome() }
                                Spacer()
                            }

                            StarRow(stars: outcome.stars, size: compact ? 28 : 36)
                            Text(loc["perfect"])
                                .font(.spDisplay(compact ? 28 : 34))
                                .foregroundStyle(Palette.gold)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .accessibilityIdentifier("result-title")
                            Text(loc["bothHappy"])
                                .font(.spScript(16))
                                .foregroundStyle(Palette.ink)
                                .multilineTextAlignment(.center)

                            HStack(alignment: .bottom, spacing: 16) {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Palette.moss)
                                    GuestPortrait(
                                        guest: .dog,
                                        happy: true,
                                        size: compact ? 96 : 120,
                                        variant: sessionVariant(for: .dog)
                                    )
                                }
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Palette.moss)
                                    GuestPortrait(
                                        guest: .cat,
                                        happy: true,
                                        size: compact ? 96 : 120,
                                        variant: sessionVariant(for: .cat)
                                    )
                                }
                            }

                            if let session = model.session {
                                HStack(spacing: 16) {
                                    plateSlice(guest: .dog, session: session, size: compact ? 96 : 120)
                                    plateSlice(guest: .cat, session: session, size: compact ? 96 : 120)
                                }
                            }

                            SPButton(
                                title: outcome.isDaily ? loc["home"] : loc["nextLevel"],
                                kind: .play,
                                icon: "play.fill"
                            ) {
                                if outcome.isDaily {
                                    model.goHome()
                                } else {
                                    model.nextLevel()
                                }
                            }
                            .accessibilityIdentifier("next-level-button")

                            Button(loc["replay"]) { model.retry() }
                                .font(.spBody(16))
                                .foregroundStyle(Palette.inkSoft)
                                .accessibilityIdentifier("replay-button")

                            Text(loc["motto"])
                                .font(.spScript(13))
                                .foregroundStyle(Palette.inkSoft)
                                .padding(.bottom, 12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .frame(maxWidth: 560)
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        } else {
            Palette.cream.onAppear { model.goHome() }
        }
    }

    private func plateSlice(guest: GuestID, session: PlaySession, size: CGFloat) -> some View {
        PlateView(plate: session.context.plate)
            .frame(width: size, height: size)
            .overlay {
                if let cut = session.draft {
                    let half = guest == .dog
                        ? (session.lastSlice?.dogHalf ?? .negative)
                        : (session.lastSlice?.dogHalf == .positive ? .negative : .positive)
                    DishCanvas(
                        kind: session.level.dish,
                        toppings: session.toppings.filter { cut.half(of: $0.position) == half },
                        cut: cut,
                        split: 0,
                        pizzaBaseAsset: session.context.pizzaBaseAsset,
                        showBoard: false
                    )
                    .clipShape(HalfDishShape(cut: cut, keepPositive: half == .positive))
                    .scaleEffect(0.5)
                }
            }
    }

    private func sessionVariant(for guest: GuestID) -> GuestVariant {
        model.session?.context.guestVariant(for: guest) ?? .classic
    }
}

struct FailView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let loc = model.loc
        if let outcome = model.lastOutcome, let session = model.session {
            GeometryReader { geo in
                let compact = geo.size.height < 800
                ZStack {
                    PicnicBackdrop(asset: outcome.world.backgroundAsset)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: compact ? 8 : 12) {
                            HStack {
                                CircleIconButton(system: "house.fill") { model.goHome() }
                                Spacer()
                            }

                            Text(loc["notQuite"])
                                .font(.spDisplay(compact ? 26 : 32))
                                .foregroundStyle(Palette.coral)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                                .accessibilityIdentifier("fail-title")
                            Text(loc["checkRequests"])
                                .font(.spBody(14))
                                .foregroundStyle(Palette.ink)
                                .multilineTextAlignment(.center)

                            HStack(alignment: .top, spacing: 8) {
                                VStack(spacing: 4) {
                                    GuestOrderCard(
                                        guest: .dog,
                                        order: session.level.dog,
                                        language: model.progress.language,
                                        happy: outcome.dogHappy,
                                        compact: true
                                    )
                                    GuestPortrait(
                                        guest: .dog,
                                        happy: outcome.dogHappy,
                                        size: compact ? 88 : 110,
                                        variant: session.context.guestVariant(for: .dog)
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                VStack(spacing: 4) {
                                    GuestOrderCard(
                                        guest: .cat,
                                        order: session.level.cat,
                                        language: model.progress.language,
                                        happy: outcome.catHappy,
                                        compact: true
                                    )
                                    GuestPortrait(
                                        guest: .cat,
                                        happy: outcome.catHappy,
                                        size: compact ? 88 : 110,
                                        variant: session.context.guestVariant(for: .cat)
                                    )
                                }
                                .frame(maxWidth: .infinity)
                            }

                            if !outcome.areaOK || !outcome.cleanCut {
                                VStack(spacing: 5) {
                                    if !outcome.areaOK {
                                        Label(loc["fairMiss"], systemImage: "circle.lefthalf.filled")
                                    }
                                    if !outcome.cleanCut {
                                        Label(loc["cleanMiss"], systemImage: "sparkles")
                                    }
                                }
                                .font(.spBody(13))
                                .foregroundStyle(Palette.coral)
                                .multilineTextAlignment(.center)
                            }

                            SPButton(title: loc["tryAgain"], kind: .danger, icon: "arrow.counterclockwise") {
                                model.screen = .play
                                model.session?.phase = .aiming
                                model.session?.lastSlice = nil
                                model.session?.draft = nil
                            }
                            .accessibilityIdentifier("try-again-button")

                            Button {
                                model.screen = .play
                                model.session?.phase = .aiming
                                model.session?.draft = nil
                                model.useHint()
                            } label: {
                                Label(loc["showHint"], systemImage: "lightbulb.fill")
                                    .font(.spBody(15))
                                    .foregroundStyle(Palette.ink)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(.white.opacity(0.92), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .disabled((model.session?.hintsLeft ?? 0) == 0)

                            Text(loc["motto"])
                                .font(.spScript(13))
                                .foregroundStyle(Palette.inkSoft)
                                .padding(.bottom, 12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .frame(maxWidth: 560)
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        } else {
            Palette.cream.onAppear { model.goHome() }
        }
    }
}
