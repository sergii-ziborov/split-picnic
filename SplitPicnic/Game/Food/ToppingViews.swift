import SwiftUI

struct ToppingSprite: View {
    var kind: ToppingKind

    var body: some View {
        Image(kind.assetName)
            .resizable()
            .scaledToFit()
            .drawingGroup()
            .shadow(color: .black.opacity(0.28), radius: 2.5, y: 1.5)
            .accessibilityHidden(true)
    }
}

struct OrderIcons: View {
    var order: GuestOrder
    var language: AppLanguage

    var body: some View {
        HStack(spacing: 4) {
            if order.isRemainder {
                Image(systemName: "gift.fill")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Palette.moss)
            } else {
                ForEach(order.required, id: \.kind) { rule in
                    HStack(spacing: 2) {
                        ToppingSprite(kind: rule.kind)
                            .frame(width: 32, height: 32)
                        if rule.min > 1 || rule.max == rule.min {
                            Text("×\(rule.min)")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(Palette.ink)
                        }
                    }
                    .padding(.horizontal, 3)
                    .background(Palette.cream.opacity(0.72), in: Capsule())
                }
                ForEach(Array(order.forbidden), id: \.self) { kind in
                    ZStack {
                        ToppingSprite(kind: kind)
                            .frame(width: 31, height: 31)
                            .opacity(0.55)
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(Palette.coral)
                            .shadow(color: .white, radius: 1)
                    }
                }
            }
        }
    }
}
