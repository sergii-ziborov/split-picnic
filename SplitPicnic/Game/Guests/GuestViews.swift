import SwiftUI

struct GuestPortrait: View {
    var guest: GuestID
    var happy: Bool
    var size: CGFloat = 140

    var body: some View {
        Image(asset)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
            .accessibilityLabel(guest == .dog ? "Dog" : "Cat")
    }

    private var asset: String {
        switch (guest, happy) {
        case (.dog, true): "DogHappy"
        case (.dog, false): "DogSad"
        case (.cat, true): "CatHappy"
        case (.cat, false): "CatSad"
        }
    }
}

struct SpeechBubble<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            )
    }
}

struct GuestOrderCard: View {
    var guest: GuestID
    var order: GuestOrder
    var language: AppLanguage
    var happy: Bool?
    var compact: Bool = false

    var body: some View {
        SpeechBubble {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    OrderIcons(order: order, language: language)
                    if let happy {
                        Image(systemName: happy ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(happy ? Palette.moss : Palette.coral)
                    }
                }
                Text(ToppingCopy.phrase(order, language: language))
                    .font(.spBody(compact ? 11 : 13))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: compact ? 150 : 180)
        }
    }
}

struct PlateView: View {
    var plate: PlateID
    var slice: ToppingKind? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, Color(red: 0.92, green: 0.90, blue: 0.88)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 80
                    )
                )
                .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

            Group {
                switch plate {
                case .paw:
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(Color(red: 0.45, green: 0.62, blue: 0.90).opacity(0.55))
                case .heart:
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color(red: 0.95, green: 0.40, blue: 0.48).opacity(0.55))
                case .daisy:
                    Image(systemName: "camera.macro")
                        .foregroundStyle(Color(red: 0.95, green: 0.78, blue: 0.22).opacity(0.7))
                }
            }
            .font(.system(size: 28, weight: .bold))
        }
    }
}
