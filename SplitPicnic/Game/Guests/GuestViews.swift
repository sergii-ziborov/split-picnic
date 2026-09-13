import SwiftUI

struct GuestPortrait: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var guest: GuestID
    var happy: Bool
    var size: CGFloat = 140
    var variant: GuestVariant = .classic

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let phase = time * (happy ? 2.7 : 5.5) + (guest == .dog ? 0 : 0.8)
            let wave = reduceMotion ? 0 : sin(phase)

            ZStack {
                Image(asset)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1 + (happy ? wave * 0.018 : 0))
                    .rotationEffect(.degrees(happy ? wave * 1.1 : wave * 0.7))
                    .offset(x: happy ? 0 : wave * 1.4, y: happy ? wave * -2.2 : abs(wave) * 1.2)

                if happy {
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.16, weight: .bold))
                        .foregroundStyle(Palette.gold)
                        .offset(x: size * 0.34, y: -size * 0.34 - wave * 3)
                        .opacity(0.55 + wave * 0.35)
                }
            }
            .frame(width: size, height: size)
            .clipped()
            .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
        }
        .accessibilityLabel(accessibilityName)
        .accessibilityIdentifier("guest-\(guest.rawValue)-\(variant.rawValue)")
    }

    private var asset: String {
        switch (variant, guest, happy) {
        case (.classic, .dog, true): "DogHappy"
        case (.classic, .dog, false): "DogSad"
        case (.classic, .cat, true): "CatHappy"
        case (.classic, .cat, false): "CatSad"
        case (.sunny, .dog, true): "DogSunnyHappy"
        case (.sunny, .dog, false): "DogSunnySad"
        case (.sunny, .cat, true): "CatGingerHappy"
        case (.sunny, .cat, false): "CatGingerSad"
        case (.woodland, .dog, true): "GuestBunnyHappy"
        case (.woodland, .dog, false): "GuestBunnySad"
        case (.woodland, .cat, true): "GuestRaccoonHappy"
        case (.woodland, .cat, false): "GuestRaccoonSad"
        }
    }

    private var accessibilityName: String {
        switch (variant, guest) {
        case (.classic, .dog): "Pip the puppy"
        case (.classic, .cat): "Miso the kitten"
        case (.sunny, .dog): "Sunny the puppy"
        case (.sunny, .cat): "Ginger the kitten"
        case (.woodland, .dog): "Clover the bunny"
        case (.woodland, .cat): "Rascal the raccoon"
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
                    .font(.spBody(compact ? 12 : 14))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(compact ? 2 : 3)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: compact ? 156 : 180)
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
