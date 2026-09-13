import Combine
import SwiftUI

struct DailyView: View {
    @Environment(AppModel.self) private var model
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let loc = model.loc
        let remaining = DailyStamp.secondsUntilReset(now: now)
        GeometryReader { geo in
            let compact = geo.size.height < 800
            ZStack {
                PicnicBackdrop(asset: "PicnicBackground")
                VStack(spacing: 0) {
                    ScreenHeader(title: loc["dailyTitle"]) { model.goHome() }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: compact ? 12 : 16) {
                WoodPanel {
                    VStack(spacing: compact ? 10 : 14) {
                        Text(loc["dailyBlurb"])
                            .font(.spScript(15))
                            .foregroundStyle(Palette.inkSoft)
                            .multilineTextAlignment(.center)

                        DishCanvas(
                            kind: LevelCatalog.level(world: .pizzaPark, index: 0).dish,
                            toppings: DishLayout.build(level: LevelCatalog.level(world: .pizzaPark, index: 0), seed: UInt64(abs(remaining))),
                            cut: .vertical,
                            split: 0
                        )
                        .frame(height: compact ? 160 : 200)
                        .allowsHitTesting(false)

                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(Palette.coral)
                            Text("\(max(model.progress.dailyStreak, model.progress.lastDailyClaim == DailyStamp.today ? model.progress.dailyStreak : 0)) \(loc["streak"])")
                                .font(.spBody(16))
                                .foregroundStyle(Palette.ink)
                        }

                        HStack(spacing: 6) {
                            ForEach(0..<5, id: \.self) { i in
                                Circle()
                                    .fill(i < min(model.progress.dailyStreak, 5) ? Palette.gold : Color.white)
                                    .overlay(Circle().stroke(Palette.gold.opacity(0.5), lineWidth: 2))
                                    .frame(width: 18, height: 18)
                            }
                        }

                        Label("\(loc["resets"]) \(clock(remaining))", systemImage: "clock")
                            .font(.spBody(13))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                .padding(.horizontal, 16)

                SPButton(title: loc["play"], kind: .play, icon: "play.fill") {
                    model.playDaily()
                }
                .padding(.horizontal, 24)
                .accessibilityIdentifier("daily-play-button")
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onReceive(timer) { now = $0 }
    }

    private func clock(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
