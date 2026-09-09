import SwiftUI

enum Palette {
    static let cream = Color(red: 0.988, green: 0.945, blue: 0.890)
    static let creamDark = Color(red: 0.94, green: 0.88, blue: 0.80)
    static let ink = Color(red: 0.28, green: 0.18, blue: 0.10)
    static let inkSoft = Color(red: 0.42, green: 0.30, blue: 0.18)
    static let wood = Color(red: 0.62, green: 0.40, blue: 0.22)
    static let woodDark = Color(red: 0.45, green: 0.28, blue: 0.14)
    static let moss = Color(red: 0.32, green: 0.78, blue: 0.42)
    static let mossDeep = Color(red: 0.18, green: 0.62, blue: 0.32)
    static let gold = Color(red: 0.98, green: 0.78, blue: 0.22)
    static let coral = Color(red: 0.92, green: 0.38, blue: 0.32)
    static let sky = Color(red: 0.45, green: 0.72, blue: 0.92)
    static let panel = Color(red: 0.99, green: 0.96, blue: 0.92)
}

extension Font {
    static func spDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func spBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func spScript(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).italic()
    }
}

struct PicnicBackdrop: View {
    var asset: String
    var dim: Double = 0.0

    var body: some View {
        Image(asset)
            .resizable()
            .scaledToFill()
            .overlay(Color.black.opacity(dim))
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

struct SPButton: View {
    enum Kind { case play, quiet, gold, danger }

    var title: String
    var kind: Kind = .play
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                }
                Text(title)
                    .font(.spDisplay(kind == .play ? 28 : 18))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, kind == .play ? 16 : 13)
            .background(background, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(kind == .quiet ? 0.0 : 0.35), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch kind {
        case .play: Palette.moss
        case .quiet: Color.white.opacity(0.94)
        case .gold: Palette.gold
        case .danger: Color(red: 0.28, green: 0.62, blue: 0.95)
        }
    }

    private var foreground: Color {
        switch kind {
        case .quiet: Palette.ink
        case .gold: Palette.ink
        default: .white
        }
    }
}

struct CircleIconButton: View {
    var system: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.92), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct StarRow: View {
    var stars: Int
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star.fill")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.gold : Color.white.opacity(0.35))
                    .shadow(color: index < stars ? Palette.gold.opacity(0.4) : .clear, radius: 4)
            }
        }
        .accessibilityLabel("\(stars) of 3 stars")
    }
}

struct ScreenHeader: View {
    var title: String
    var back: () -> Void

    var body: some View {
        HStack {
            CircleIconButton(system: "chevron.left", action: back)
                .accessibilityIdentifier("back-button")
            Spacer()
            Text(title)
                .font(.spDisplay(28))
                .foregroundStyle(Palette.ink)
                .shadow(color: .white.opacity(0.8), radius: 4)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

struct WoodPanel<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Palette.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Palette.wood.opacity(0.35), lineWidth: 8)
                    )
                    .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
            )
    }
}

struct Gingham: View {
    var color: Color
    var cell: CGFloat = 18

    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white.opacity(0.92)))
            var x: CGFloat = 0
            while x < size.width {
                let path = Path(CGRect(x: x, y: 0, width: cell / 2, height: size.height))
                ctx.fill(path, with: .color(color.opacity(0.22)))
                x += cell
            }
            var y: CGFloat = 0
            while y < size.height {
                let path = Path(CGRect(x: 0, y: y, width: size.width, height: cell / 2))
                ctx.fill(path, with: .color(color.opacity(0.18)))
                y += cell
            }
        }
        .allowsHitTesting(false)
    }
}
