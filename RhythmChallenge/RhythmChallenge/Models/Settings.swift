import Foundation
import SwiftUI

class Settings: ObservableObject {
    // MARK: - Published properties
    @Published var bpm: Double {
        didSet {
            UserDefaults.standard.set(bpm, forKey: "bpm")
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        }
    }
    
    @Published var trainingMode: TrainingMode {
        didSet {
            UserDefaults.standard.set(trainingMode.rawValue, forKey: "trainingMode")
        }
    }
    
    // MARK: - Static constants
    static let minBPM: Double = 40.0
    static let maxBPM: Double = 160.0
    static let defaultBPM: Double = 90.0
    
    // MARK: - Initialization
    init() {
        // Load saved values or use defaults
        self.bpm = UserDefaults.standard.object(forKey: "bpm") as? Double ?? Settings.defaultBPM
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
        
        if let savedModeValue = UserDefaults.standard.string(forKey: "trainingMode"),
           let savedMode = TrainingMode(rawValue: savedModeValue) {
            self.trainingMode = savedMode
        } else {
            self.trainingMode = .tap
        }
    }
    
    // MARK: - Public methods
    func resetToDefaults() {
        bpm = Settings.defaultBPM
        hapticFeedbackEnabled = true
        trainingMode = .tap
    }
    
    // MARK: - Training mode enum
    enum TrainingMode: String, CaseIterable, Identifiable {
        case tap = "Тап"
        case microphone = "Микрофон"
        
        var id: String { self.rawValue }
    }
}