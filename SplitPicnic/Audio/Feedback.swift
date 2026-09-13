import AVFoundation
import UIKit

@MainActor
enum Feedback {
    static func tap(sound: Bool, haptics: Bool) {
        if haptics { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        if sound { GameAudio.shared.play(.select) }
    }

    static func swipe(sound: Bool, haptics: Bool) {
        if haptics { UISelectionFeedbackGenerator().selectionChanged() }
        if sound { GameAudio.shared.play(.swipe) }
    }

    static func slice(sound: Bool, haptics: Bool) {
        if haptics { UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.86) }
        if sound { GameAudio.shared.play(.slice) }
    }

    static func success(sound: Bool, haptics: Bool) {
        if haptics { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        if sound { GameAudio.shared.play(.success) }
    }

    static func miss(sound: Bool, haptics: Bool) {
        if haptics { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
        if sound { GameAudio.shared.play(.miss) }
    }

    static func hint(sound: Bool, haptics: Bool) {
        if haptics { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        if sound { GameAudio.shared.play(.hint) }
    }

    static func ready(sound: Bool) {
        if sound { GameAudio.shared.play(.ready) }
    }
}

@MainActor
private final class GameAudio {
    static let shared = GameAudio()

    enum Cue: CaseIterable, Hashable {
        case select
        case swipe
        case slice
        case success
        case miss
        case hint
        case ready
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate = 44_100.0
    private let format: AVAudioFormat
    private var buffers: [Cue: AVAudioPCMBuffer] = [:]

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.58
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for cue in Cue.allCases {
            buffers[cue] = makeBuffer(for: cue)
        }
        engine.prepare()
    }

    func play(_ cue: Cue) {
        guard let buffer = buffers[cue] else { return }
        do {
            if !engine.isRunning { try engine.start() }
            player.scheduleBuffer(buffer, at: nil, options: .interrupts)
            player.play()
        } catch {
            // Sound is optional; gameplay remains available if audio cannot start.
        }
    }

    private func makeBuffer(for cue: Cue) -> AVAudioPCMBuffer {
        let duration = duration(for: cue)
        let frames = AVAudioFrameCount(duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let channel = buffer.floatChannelData![0]
        var noiseState: UInt32 = 0x51_1C_E5

        for frame in 0..<Int(frames) {
            let time = Double(frame) / sampleRate
            let progress = min(1, time / duration)
            noiseState = noiseState &* 1_664_525 &+ 1_013_904_223
            let noise = Double(noiseState & 0xFFFF) / 32_767.5 - 1
            let value = sample(cue: cue, time: time, progress: progress, noise: noise)
            channel[frame] = Float(max(-0.94, min(0.94, value)))
        }
        return buffer
    }

    private func duration(for cue: Cue) -> Double {
        switch cue {
        case .select: 0.09
        case .swipe: 0.16
        case .slice: 0.28
        case .success: 0.66
        case .miss: 0.42
        case .hint: 0.42
        case .ready: 0.30
        }
    }

    private func sample(cue: Cue, time: Double, progress: Double, noise: Double) -> Double {
        let tau = Double.pi * 2
        let fade = pow(max(0, 1 - progress), 1.7)

        switch cue {
        case .select:
            return sin(tau * 620 * time) * fade * 0.24

        case .swipe:
            let frequency = 420 + progress * 1_050
            return (sin(tau * frequency * time) * 0.12 + noise * 0.11) * fade

        case .slice:
            let blade = sin(tau * (1_150 - progress * 780) * time) * 0.22
            let crunch = noise * (0.34 + 0.14 * sin(tau * 92 * time))
            return (blade + crunch) * pow(max(0, 1 - progress), 2.4)

        case .success:
            let notes = [523.25, 659.25, 783.99, 1_046.50]
            let segment = min(notes.count - 1, Int(progress * Double(notes.count)))
            let local = (progress * Double(notes.count)).truncatingRemainder(dividingBy: 1)
            let bell = sin(tau * notes[segment] * time) + sin(tau * notes[segment] * 2 * time) * 0.28
            return bell * sin(Double.pi * min(1, local)) * 0.22

        case .miss:
            let frequency = progress < 0.48 ? 330.0 : 233.08
            return (sin(tau * frequency * time) + sin(tau * frequency * 0.5 * time) * 0.32) * fade * 0.22

        case .hint:
            let frequency = 820 + progress * 880
            let shimmer = sin(tau * frequency * time) + sin(tau * frequency * 1.51 * time) * 0.4
            return shimmer * sin(Double.pi * progress) * 0.17

        case .ready:
            let frequency = progress < 0.5 ? 440.0 : 659.25
            return sin(tau * frequency * time) * sin(Double.pi * progress) * 0.20
        }
    }
}
