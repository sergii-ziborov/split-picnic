import SwiftUI

struct WorldsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            PicnicBackdrop(asset: "WorldsMap", dim: 0.08)
            VStack(spacing: 0) {
                ScreenHeader(title: model.loc["worlds"]) { model.goHome() }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
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
        let completion = levels.isEmpty ? 0 : Double(cleared) / Double(levels.count)

        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                Image(world.backgroundAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 146)
                    .clipped()
                    .saturation(unlocked ? 0.72 + completion * 0.34 : 0.18)
                    .brightness(unlocked ? -0.07 + completion * 0.08 : -0.12)
                    .overlay {
                        LinearGradient(
                            colors: [.black.opacity(0.06), .clear, Palette.ink.opacity(0.62)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .overlay {
                        if !unlocked { Color.black.opacity(0.3) }
                    }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Label("\(model.loc["picnic"]) \(worldNumber(world))", systemImage: picnicIcon(world))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.24), in: Capsule())

                        Spacer()

                        if unlocked {
                            milestoneDecorations(cleared: cleared)
                        }
                    }

                    Spacer()

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(world.title)
                                .font(.spDisplay(22))
                                .foregroundStyle(.white)
                            Text(unlocked ? picnicStage(cleared: cleared, total: levels.count) : world.subtitle)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.93))
                        }
                        Spacer()
                        if unlocked {
                            Text("\(cleared)/\(levels.count)")
                                .font(.spBody(13))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.22), in: Capsule())
                        } else {
                            Label(model.loc["locked"], systemImage: "lock.fill")
                                .font(.spBody(12))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            if unlocked {
                HStack(spacing: 8) {
                    Label(
                        picnicStage(cleared: cleared, total: levels.count),
                        systemImage: stageIcon(cleared: cleared, total: levels.count)
                    )
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)

                    Spacer()

                    ProgressView(value: completion)
                        .tint(levelColor(max(1, worldNumber(world))))
                        .frame(width: 92)
                }
                .padding(.horizontal, 4)

                picnicTrail(levels, world: world)
            } else {
                Text("\(world.starsToUnlock) ★")
                    .font(.spBody(13))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.horizontal, 4)
            }
        }
        .padding(12)
        .background(.white.opacity(0.93), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private func picnicTrail(_ levels: [LevelDef], world: WorldID) -> some View {
        let firstUncleared = levels.firstIndex { model.progress.stars(for: $0) == 0 }

        return GeometryReader { geo in
            let points = levels.indices.map { trailPoint(index: $0, size: geo.size) }

            ZStack {
                ForEach(0..<(max(0, points.count - 1)), id: \.self) { index in
                    Path { path in
                        path.move(to: points[index])
                        path.addLine(to: points[index + 1])
                    }
                    .stroke(
                        index < (firstUncleared ?? levels.count) ? Palette.gold : Palette.wood.opacity(0.22),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: index < (firstUncleared ?? levels.count) ? [] : [5, 8])
                    )
                }

                ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                    let stars = model.progress.stars(for: level)
                    let completed = stars > 0
                    let current = index == firstUncleared

                    Button {
                        model.play(world: world, index: level.index)
                    } label: {
                        VStack(spacing: 1) {
                            Text("\(level.number)")
                                .font(.spDisplay(15))
                                .foregroundStyle(completed ? .white : Palette.ink)
                            if completed {
                                StarRow(stars: stars, size: 7)
                            } else if level.difficulty >= 4 {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Palette.coral)
                            }
                        }
                        .frame(width: 50, height: 42)
                        .background(
                            completed
                                ? levelColor(level.difficulty)
                                : current ? Color.white : Palette.creamDark.opacity(0.94),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    current ? Palette.gold : Color.white.opacity(completed ? 0.65 : 0.92),
                                    lineWidth: current ? 3 : 1.5
                                )
                        }
                        .shadow(
                            color: current ? Palette.gold.opacity(0.35) : .black.opacity(0.11),
                            radius: current ? 7 : 3,
                            y: 2
                        )
                    }
                    .buttonStyle(.plain)
                    .position(points[index])
                    .accessibilityIdentifier("level-\(world.rawValue)-\(level.index)")
                }
            }
        }
        .frame(height: 178)
        .padding(.horizontal, 2)
        .background(
            LinearGradient(
                colors: [Palette.cream.opacity(0.88), Palette.creamDark.opacity(0.46)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private func trailPoint(index: Int, size: CGSize) -> CGPoint {
        let row = index / 4
        let columnInRow = index % 4
        let column = row.isMultiple(of: 2) ? columnInRow : 3 - columnInRow
        let horizontalInset = min(34, size.width * 0.1)
        let xStep = (size.width - horizontalInset * 2) / 3
        let yStep = (size.height - 46) / 2
        return CGPoint(
            x: horizontalInset + CGFloat(column) * xStep,
            y: 23 + CGFloat(row) * yStep
        )
    }

    @ViewBuilder
    private func milestoneDecorations(cleared: Int) -> some View {
        HStack(spacing: 6) {
            if cleared >= 1 { milestone("fork.knife") }
            if cleared >= 4 { milestone("basket.fill") }
            if cleared >= 8 { milestone("person.2.fill") }
            if cleared >= 12 { milestone("sparkles") }
        }
    }

    private func milestone(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Palette.gold)
            .frame(width: 26, height: 26)
            .background(.white.opacity(0.9), in: Circle())
            .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
    }

    private func picnicStage(cleared: Int, total: Int) -> String {
        switch cleared {
        case 0: model.loc["picnicPreparing"]
        case 1..<4: model.loc["picnicTableSet"]
        case 4..<8: model.loc["picnicFriendsArriving"]
        case 8..<total: model.loc["picnicInFullSwing"]
        default: model.loc["picnicComplete"]
        }
    }

    private func stageIcon(cleared: Int, total: Int) -> String {
        switch cleared {
        case 0: "basket"
        case 1..<4: "fork.knife"
        case 4..<8: "figure.wave"
        case 8..<total: "music.note"
        default: "sparkles"
        }
    }

    private func picnicIcon(_ world: WorldID) -> String {
        switch world {
        case .pizzaPark: "fork.knife"
        case .berryMeadow: "birthday.cake.fill"
        case .forestPicnic: "leaf.fill"
        case .sunsetBakery: "sun.horizon.fill"
        }
    }

    private func worldNumber(_ world: WorldID) -> Int {
        (WorldID.allCases.firstIndex(of: world) ?? 0) + 1
    }

    private func levelColor(_ difficulty: Int) -> Color {
        switch difficulty {
        case 1: Palette.moss
        case 2: Palette.sky
        case 3: Palette.gold
        case 4: Palette.coral
        default: Color(red: 0.64, green: 0.32, blue: 0.82)
        }
    }
}
