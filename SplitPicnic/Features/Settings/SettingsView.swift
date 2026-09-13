import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        @Bindable var model = model
        let loc = model.loc
        ZStack {
            PicnicBackdrop(asset: "PicnicBackground")
            VStack(spacing: 0) {
                ScreenHeader(title: loc["settings"]) { model.goHome() }

                ScrollView(showsIndicators: false) {
                    Button {
                        model.openTutorial(from: .settings)
                    } label: {
                        Label(loc["howToPlay"], systemImage: "play.rectangle.fill")
                            .font(.spBody(17))
                            .foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .accessibilityIdentifier("settings-tutorial")
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    WoodPanel {
                        VStack(spacing: 12) {
                            toggleRow("speaker.wave.2.fill", loc["sound"], loc["soundSub"], $model.progress.soundEnabled)
                            toggleRow("music.note", loc["music"], loc["musicSub"], $model.progress.musicEnabled)
                            toggleRow("iphone.radiowaves.left.and.right", loc["haptics"], loc["hapticsSub"], $model.progress.hapticsEnabled)

                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(Palette.wood)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc["language"])
                                        .font(.spBody(16))
                                        .foregroundStyle(Palette.ink)
                                    Text(loc["languageSub"])
                                        .font(.system(size: 12))
                                        .foregroundStyle(Palette.inkSoft)
                                }
                                Spacer()
                                Picker("", selection: $model.progress.language) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.title).tag(lang)
                                    }
                                }
                                .labelsHidden()
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                            toggleRow("figure.run", loc["reduceMotion"], loc["reduceMotionSub"], $model.progress.reduceMotion)
                        }
                    }
                    .padding(16)

                    WoodPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            LabeledContent("Stars", value: "\(model.progress.totalStars)")
                            LabeledContent("Solves", value: "\(model.progress.totalSolves)")
                            LabeledContent(loc["version"], value: "1.0.0")
                            Text(loc["about"])
                                .font(.system(size: 14))
                                .foregroundStyle(Palette.inkSoft)
                            Button(loc["reset"], role: .destructive) { confirmReset = true }
                                .font(.spBody(15))
                        }
                    }
                    .padding(.horizontal, 16)

                    Text(loc["motto"])
                        .font(.spScript(14))
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.vertical, 16)
                }
            }
        }
        .onChange(of: model.progress.soundEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.musicEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.hapticsEnabled) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.reduceMotion) { _, _ in model.saveProgress() }
        .onChange(of: model.progress.language) { _, _ in model.saveProgress() }
        .confirmationDialog("Reset all stars and collection?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func toggleRow(_ icon: String, _ title: String, _ subtitle: String, _ binding: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Palette.wood)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.spBody(16))
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.inkSoft)
            }
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(Palette.moss)
        }
        .padding(12)
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
