import AudioToolbox
import UIKit

enum Feedback {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func slice(sound: Bool) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if sound { AudioServicesPlaySystemSound(1104) }
    }

    static func success(sound: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if sound { AudioServicesPlaySystemSound(1025) }
    }

    static func miss(sound: Bool) {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        if sound { AudioServicesPlaySystemSound(1053) }
    }

    static func hint() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
