import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let loc = model.loc
        if let outcome = model.lastOutcome {
            ZStack {
                PicnicBackdrop(asset: outcome.world.backgroundAsset)
                Gingham(color: Color(red: 0.86, green: 0.22, blue: 0.22), cell: 20)
                    .opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    HStack {
                        CircleIconButton(system: "house.fill") { model.goHome() }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    StarRow(stars: outcome.stars, size: 36)
                    Text(loc["perfect"])
                        .font(.spDisplay(34))
                        .foregroundStyle(Palette.gold)
                        .shadow(color: .black.opacity(0.15), radius: 4)
                        .accessibilityIdentifier("result-title")
                    Text(loc["bothHappy"])
                        .font(.spScript(18))
                        .foregroundStyle(Palette.ink)

                    HStack(alignment: .bottom, spacing: 18) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Palette.moss)
                            GuestPortrait(guest: .dog, happy: true, size: 128)
                        }
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Palette.moss)
                            GuestPortrait(guest: .cat, happy: true, size: 128)
                        }
                    }

                    if let session = model.session {
                        HStack(spacing: 24) {
                            plateSlice(guest: .dog, session: session)
                            plateSlice(guest: .cat, session: session)
                        }
                        .padding(.horizontal, 20)
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
                    .padding(.horizontal, 28)
                    .accessibilityIdentifier("next-level-button")

                    Button(loc["replay"]) { model.retry() }
                        .font(.spBody(16))
                        .foregroundStyle(Palette.inkSoft)
                        .accessibilityIdentifier("replay-button")

                    Text(loc["motto"])
                        .font(.spScript(13))
                        .foregroundStyle(Palette.inkSoft)
                    Spacer(minLength: 8)
                }
                .padding(.top, 8)
            }
        } else {
            Palette.cream.onAppear { model.goHome() }
        }
    }

    private func plateSlice(guest: GuestID, session: PlaySession) -> some View {
        VStack {
            PlateView(plate: session.context.plate)
                .frame(width: 120, height: 120)
                .overlay {
                    if let cut = session.draft {
                        let half = guest == .dog ? (session.lastSlice?.dogHalf ?? .negative) : (session.lastSlice?.dogHalf == .positive ? .negative : .positive)
                        DishCanvas(
                            kind: session.level.dish,
                            toppings: session.toppings.filter { cut.half(of: $0.position) == half },
                            cut: cut,
                            split: 0
                        )
                        .clipShape(HalfDishShape(cut: cut, keepPositive: half == .positive))
                        .scaleEffect(0.55)
                    }
                }
        }
    }
}

struct FailView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let loc = model.loc
        if let outcome = model.lastOutcome, let session = model.session {
            ZStack {
                PicnicBackdrop(asset: outcome.world.backgroundAsset)
                Gingham(color: Color(red: 0.86, green: 0.22, blue: 0.22), cell: 20)
                    .opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    HStack {
                        CircleIconButton(system: "house.fill") { model.goHome() }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    Text(loc["notQuite"])
                        .font(.spDisplay(32))
                        .foregroundStyle(Palette.coral)
                        .accessibilityIdentifier("fail-title")
                    Text(loc["checkRequests"])
                        .font(.spBody(15))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    HStack(alignment: .top, spacing: 10) {
                        VStack {
                            GuestOrderCard(
                                guest: .dog,
                                order: session.level.dog,
                                language: model.progress.language,
                                happy: outcome.dogHappy,
                                compact: true
                            )
                            GuestPortrait(guest: .dog, happy: outcome.dogHappy, size: 120)
                        }
                        VStack {
                            GuestOrderCard(
                                guest: .cat,
                                order: session.level.cat,
                                language: model.progress.language,
                                happy: outcome.catHappy,
                                compact: true
                            )
                            GuestPortrait(guest: .cat, happy: outcome.catHappy, size: 120)
                        }
                    }
                    .padding(.horizontal, 8)

                    if !outcome.areaOK {
                        Text(loc["fair"])
                            .font(.spBody(14))
                            .foregroundStyle(Palette.coral)
                    }

                    SPButton(title: loc["tryAgain"], kind: .danger, icon: "arrow.counterclockwise") {
                        model.screen = .play
                        model.session?.phase = .aiming
                        model.session?.lastSlice = nil
                    }
                    .padding(.horizontal, 28)
                    .accessibilityIdentifier("try-again-button")

                    Button {
                        model.screen = .play
                        model.session?.phase = .aiming
                        model.useHint()
                    } label: {
                        Label(loc["showHint"], systemImage: "lightbulb.fill")
                            .font(.spBody(16))
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
                    Spacer(minLength: 8)
                }
                .padding(.top, 8)
            }
        } else {
            Palette.cream.onAppear { model.goHome() }
        }
    }
}
