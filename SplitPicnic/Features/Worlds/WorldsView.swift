import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            PicnicBackdrop(asset: "WorldsMap", dim: 0.08)
            VStack(spacing: 0) {
                ScreenHeader(title: model.loc["worlds"]) { model.goHome() }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(WorldID.allCases) { world in
                            worldCard(world)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func worldCard(_ world: WorldID) -> some View {
        let unlocked = model.progress.isUnlocked(world)
        let levels = LevelCatalog.levels(for: world)
        let cleared = model.progress.clearedCount(in: world)

        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 124)
                    .clipped()
                    .overlay {
                        LinearGradient(colors: [.clear, Palette.ink.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    }
                    .overlay {
                        if !unlocked { Color.black.opacity(0.28) }
                    }

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(world.title)
                            .font(.spDisplay(22))
                            .foregroundStyle(.white)
                        Text(world.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Spacer()
                    if unlocked {
                        Text("\(cleared)/\(levels.count)")
                            .font(.spBody(13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.2), in: Capsule())
                    } else {
                        Label(model.loc["locked"], systemImage: "lock.fill")
                            .font(.spBody(12))
                            .foregroundStyle(.white)
                    }
                }
                .padding(12)
            }

            if unlocked {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(levels) { level in
                        Button {
                            model.play(world: world, index: level.index)
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(level.number)")
                                    .font(.spDisplay(16))
                                    .foregroundStyle(Palette.ink)
                                StarRow(stars: model.progress.stars(for: level), size: 9)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Palette.gold.opacity(0.95), in: Circle())
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("level-\(world.rawValue)-\(level.index)")
                    }
                }
            } else {
                Text("\(world.starsToUnlock) ★")
                    .font(.spBody(13))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.horizontal, 4)
            }
        }
        .padding(12)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
}
