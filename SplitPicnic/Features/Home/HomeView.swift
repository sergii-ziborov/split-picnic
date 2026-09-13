import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let loc = model.loc
        GeometryReader { geo in
            let h = geo.size.height
            let tight = h < 700
            let compact = h < 860
            ZStack {
                PicnicBackdrop(asset: "PicnicBackground")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: tight ? 8 : compact ? 10 : 14) {
                        HStack {
                            CircleIconButton(system: "gearshape.fill") { model.screen = .settings }
                                .accessibilityIdentifier("home-settings")
                            Spacer()
                        }

                        title(loc: loc, compact: compact, tight: tight)

                        HStack(alignment: .bottom, spacing: 8) {
                            GuestPortrait(
                                guest: .dog,
                                happy: true,
                                size: tight ? 72 : compact ? 92 : 120,
                                variant: nextPicnicContext.guestVariant(for: .dog)
                            )
                            Spacer(minLength: 0)
                            GuestPortrait(
                                guest: .cat,
                                happy: true,
                                size: tight ? 72 : compact ? 92 : 120,
                                variant: nextPicnicContext.guestVariant(for: .cat)
                            )
                        }

                        heroDish
                            .frame(height: tight ? 150 : compact ? 190 : 240)
                            .frame(maxWidth: 360)
                            .frame(maxWidth: .infinity)

                        SPButton(title: loc["play"], kind: .play, icon: "play.fill") {
                            model.playTapped()
                        }
                        .accessibilityIdentifier("play-button")

                        HStack(spacing: 8) {
                            mini(loc["worlds"], icon: "map.fill") { model.screen = .worlds }
                                .accessibilityIdentifier("worlds-button")
                            mini(loc["daily"], icon: "calendar") { model.screen = .daily }
                                .accessibilityIdentifier("daily-button")
                            mini(loc["collection"], icon: "square.grid.2x2.fill") { model.screen = .collection }
                                .accessibilityIdentifier("collection-button")
                        }

                        Button {
                            model.screen = .settings
                        } label: {
                            Label(loc["settings"], systemImage: "gearshape.fill")
                                .font(.spBody(15))
                                .foregroundStyle(Palette.ink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.94), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings-button")

                        Text(loc["motto"])
                            .font(.spScript(13))
                            .foregroundStyle(Palette.inkSoft)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func title(loc: L10n, compact: Bool, tight: Bool) -> some View {
        VStack(spacing: 4) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: tight ? 56 : compact ? 68 : 84, height: tight ? 56 : compact ? 68 : 84)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.16), radius: 8, y: 4)

            Text("Split Picnic")
                .font(.spDisplay(tight ? 28 : compact ? 34 : 40))
                .foregroundStyle(Palette.ink)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .accessibilityIdentifier("home-title")

            Text(loc["tagline"])
                .font(.spScript(tight ? 14 : 16))
                .foregroundStyle(Palette.wood)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private var heroDish: some View {
        let demo = LevelCatalog.level(world: .pizzaPark, index: 0)
        let toppings = DishLayout.build(level: demo, seed: 7)
        return DishCanvas(
            kind: .pizza,
            toppings: toppings,
            cut: Cut.vertical,
            split: 0,
            pizzaBaseAsset: nextPicnicContext.pizzaBaseAsset
        )
            .allowsHitTesting(false)
    }

    private var nextPicnicContext: PlayContext {
        let next = model.progress.nextPlayable()
        return PlayContext(
            world: next.0,
            levelIndex: next.1,
            seed: 7,
            isDaily: false,
            theme: model.progress.theme(for: next.0, levelIndex: next.1),
            plate: model.progress.selectedPlate
        )
    }

    private func mini(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Palette.wood)
                Text(title)
                    .font(.spBody(11))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}
