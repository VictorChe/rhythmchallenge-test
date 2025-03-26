import Foundation
import UIKit

class HapticsService {
    enum HapticType {
        case success
        case warning
        case error
        case light
        case medium
        case heavy
    }
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Prepare all generators
    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    // Play the specified haptic feedback
    func playHaptic(_ type: HapticType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch type {
            case .success:
                self.notificationGenerator.notificationOccurred(.success)
            case .warning:
                self.notificationGenerator.notificationOccurred(.warning)
            case .error:
                self.notificationGenerator.notificationOccurred(.error)
            case .light:
                self.lightGenerator.impactOccurred()
            case .medium:
                self.mediumGenerator.impactOccurred()
            case .heavy:
                self.heavyGenerator.impactOccurred()
            }
        }
    }
    
    // Play selection feedback
    func playSelection() {
        DispatchQueue.main.async { [weak self] in
            self?.selectionGenerator.selectionChanged()
        }
    }
}