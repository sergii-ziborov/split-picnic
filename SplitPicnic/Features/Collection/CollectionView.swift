import SwiftUI

struct CollectionView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: Tab = .themes

    enum Tab: String, CaseIterable {
        case themes
        case food
        case guests
    }

    var body: some View {
        let loc = model.loc
        ZStack {
            PicnicBackdrop(asset: "PicnicBackground", dim: 0.05)
            VStack(spacing: 0) {
                ScreenHeader(title: loc["collection"]) { model.goHome() }

                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { item in
                        Button {
                            tab = item
                        } label: {
                            Text(label(item, loc: loc))
                                .font(.spBody(14))
                                .foregroundStyle(tab == item ? .white : Palette.ink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(tab == item ? Palette.moss : Color.clear, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(.white.opacity(0.9), in: Capsule())
                .padding(.horizontal, 16)

                ScrollView(showsIndicators: false) {
                    switch tab {
                    case .themes:
                        themeGrid
                    case .food:
                        foodGrid
                    case .guests:
                        guestGrid
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    private func label(_ tab: Tab, loc: L10n) -> String {
        switch tab {
        case .themes: loc["themes"]
        case .food: loc["food"]
        case .guests: loc["guests"]
        }
    }

    private var themeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ThemeID.allCases) { theme in
                themeCard(theme)
            }
        }
        .padding(16)
    }

    private func themeCard(_ theme: ThemeID) -> some View {
        let unlocked = model.progress.isThemeUnlocked(theme)
        let equipped = model.progress.selectedTheme == theme
        let loc = model.loc
        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: theme.cloth.red, green: theme.cloth.green, blue: theme.cloth.blue).opacity(0.55))
                .overlay {
                    Gingham(color: Color(red: theme.cloth.red, green: theme.cloth.green, blue: theme.cloth.blue), cell: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .overlay {
                    if !unlocked {
                        Color.black.opacity(0.25)
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .frame(height: 110)

            Text(theme.title)
                .font(.spBody(14))
                .foregroundStyle(Palette.ink)

            if equipped {
                Text(loc["equipped"])
                    .font(.spBody(12))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Palette.moss, in: Capsule())
            } else if unlocked {
                Button(loc["owned"]) { model.selectTheme(theme) }
                    .font(.spBody(12))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Palette.creamDark, in: Capsule())
            } else {
                Label("\(theme.starsToUnlock)", systemImage: "star.fill")
                    .font(.spBody(12))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Palette.gold, in: Capsule())
            }
        }
        .padding(10)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }

    private var foodGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ToppingKind.allCases) { kind in
                VStack(spacing: 8) {
                    ToppingSprite(kind: kind)
                        .frame(width: 52, height: 52)
                    Text(ToppingCopy.name(kind, language: model.progress.language))
                        .font(.spBody(11))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(16)
    }

    private var guestGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack {
                    GuestPortrait(guest: .dog, happy: true, size: 140)
                    Text("Pip")
                        .font(.spBody(16))
                }
                VStack {
                    GuestPortrait(guest: .cat, happy: true, size: 140)
                    Text("Miso")
                        .font(.spBody(16))
                }
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(PlateID.allCases) { plate in
                    plateCard(plate)
                }
            }
        }
        .padding(16)
    }

    private func plateCard(_ plate: PlateID) -> some View {
        let unlocked = model.progress.isPlateUnlocked(plate)
        let equipped = model.progress.selectedPlate == plate
        let loc = model.loc
        return VStack(spacing: 8) {
            PlateView(plate: plate)
                .frame(height: 88)
                .overlay {
                    if !unlocked {
                        Color.white.opacity(0.35)
                        Image(systemName: "lock.fill")
                    }
                }
            Text(plate.title)
                .font(.spBody(12))
                .foregroundStyle(Palette.ink)
            if equipped {
                Text(loc["equipped"])
                    .font(.spBody(11))
                    .foregroundStyle(Palette.moss)
            } else if unlocked {
                Button(loc["owned"]) { model.selectPlate(plate) }
                    .font(.spBody(11))
            } else {
                Label("\(plate.starsToUnlock)", systemImage: "star.fill")
                    .font(.spBody(11))
                    .foregroundStyle(Palette.gold)
            }
        }
        .padding(8)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
