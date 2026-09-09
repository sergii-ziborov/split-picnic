import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let loc = model.loc
        GeometryReader { geo in
            let short = geo.size.height < 740
            ZStack {
                PicnicBackdrop(asset: "PicnicBackground")
                Gingham(color: Color(red: 0.86, green: 0.22, blue: 0.22), cell: 20)
                    .opacity(0.12)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: short ? 10 : 16) {
                        HStack {
                            CircleIconButton(system: "gearshape.fill") { model.screen = .settings }
                                .accessibilityIdentifier("home-settings")
                            Spacer()
                        }
                        .padding(.horizontal, 8)

                        title(loc: loc, short: short)

                        HStack(alignment: .bottom) {
                            GuestPortrait(guest: .dog, happy: true, size: short ? 110 : 132)
                            Spacer()
                            GuestPortrait(guest: .cat, happy: true, size: short ? 110 : 132)
                        }
                        .padding(.horizontal, 8)

                        heroDish
                            .frame(height: short ? 210 : 250)

                        SPButton(title: loc["play"], kind: .play, icon: "play.fill") {
                            model.playTapped()
                        }
                        .accessibilityIdentifier("play-button")
                        .padding(.horizontal, 12)

                        HStack(spacing: 10) {
                            mini(loc["worlds"], icon: "map.fill") { model.screen = .worlds }
                                .accessibilityIdentifier("worlds-button")
                            mini(loc["daily"], icon: "calendar") { model.screen = .daily }
                                .accessibilityIdentifier("daily-button")
                            mini(loc["collection"], icon: "square.grid.2x2.fill") { model.screen = .collection }
                                .accessibilityIdentifier("collection-button")
                        }

                        SPButton(title: loc["settings"], kind: .quiet, icon: "gearshape.fill") {
                            model.screen = .settings
                        }
                        .accessibilityIdentifier("settings-button")

                        Text(loc["motto"])
                            .font(.spScript(14))
                            .foregroundStyle(Palette.inkSoft)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, short ? 8 : 18)
                    .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func title(loc: L10n, short: Bool) -> some View {
        VStack(spacing: 6) {
            Image("BrandMark")
                .resizable()
                .scaledToFit()
                .frame(width: short ? 72 : 88, height: short ? 72 : 88)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.16), radius: 10, y: 6)

            Text("Split Picnic")
                .font(.spDisplay(short ? 36 : 42))
                .foregroundStyle(Palette.ink)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .accessibilityIdentifier("home-title")

            Text(loc["tagline"])
                .font(.spScript(short ? 16 : 18))
                .foregroundStyle(Palette.wood)
        }
    }

    private var heroDish: some View {
        let demo = LevelCatalog.level(world: .pizzaPark, index: 0)
        let toppings = DishLayout.build(level: demo, seed: 7)
        return DishCanvas(kind: .pizza, toppings: toppings, cut: Cut.vertical, split: 0)
            .allowsHitTesting(false)
    }

    private func mini(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Palette.wood)
                Text(title)
                    .font(.spBody(12))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}
