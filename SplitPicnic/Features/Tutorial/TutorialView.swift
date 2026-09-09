import SwiftUI

struct TutorialView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    var body: some View {
        let loc = model.loc
        let pages = [
            loc["drawLine"],
            loc["tutorial2"],
            loc["tutorial3"],
        ]
        ZStack {
            PicnicBackdrop(asset: "PicnicBackground")
            VStack(spacing: 12) {
                HStack {
                    CircleIconButton(system: "chevron.left") {
                        if page == 0 { model.goHome() } else { page -= 1 }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)

                Text(loc["howToPlay"])
                    .font(.spDisplay(30))
                    .foregroundStyle(Palette.ink)
                Text("\(page + 1)/3")
                    .font(.spBody(14))
                    .foregroundStyle(Palette.inkSoft)

                HStack(alignment: .bottom) {
                    GuestPortrait(guest: .dog, happy: true, size: 120)
                    Spacer()
                    GuestPortrait(guest: .cat, happy: true, size: 120)
                }
                .padding(.horizontal, 16)

                DishCanvas(
                    kind: .pizza,
                    toppings: DishLayout.build(level: LevelCatalog.level(world: .pizzaPark, index: 0), seed: 3),
                    cut: .vertical,
                    split: 0
                )
                .frame(height: 240)
                .overlay {
                    CutOverlay(
                        cut: .vertical,
                        hint: nil,
                        showHint: false,
                        handles: true,
                        center: CGPoint(x: 180, y: 120),
                        radius: 100
                    )
                    .allowsHitTesting(false)
                }

                Text(pages[page])
                    .font(.spBody(17))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: 360)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 20)

                SPButton(
                    title: page == 2 ? loc["startPicnic"] : loc["next"],
                    kind: .play,
                    icon: page == 2 ? "play.fill" : "arrow.right"
                ) {
                    if page == 2 {
                        model.finishTutorial()
                    } else {
                        page += 1
                    }
                }
                .padding(.horizontal, 32)
                .accessibilityIdentifier("tutorial-next")

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Palette.moss : Palette.creamDark)
                            .frame(width: 8, height: 8)
                    }
                }
                Spacer()
            }
            .padding(.top, 8)
        }
    }
}
