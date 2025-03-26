import Foundation
import Combine

class Settings: ObservableObject {
    
    // MARK: - Published properties
    @Published var bpm: Double {
        didSet {
            UserDefaults.standard.set(bpm, forKey: "bpm")
        }
    }
    
    @Published var trainingMode: TrainingMode {
        didSet {
            UserDefaults.standard.set(trainingMode.rawValue, forKey: "trainingMode")
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
        }
    }
    
    // MARK: - Enums
    enum TrainingMode: String, CaseIterable, Identifiable {
        case tap = "Режим тапов"
        case microphone = "Режим микрофона"
        
        var id: String { self.rawValue }
    }
    
    // MARK: - Constants
    static let minBPM: Double = 40.0
    static let maxBPM: Double = 160.0
    static let defaultBPM: Double = 90.0
    
    // MARK: - Initialization
    init() {
        // Load saved settings or use defaults
        self.bpm = UserDefaults.standard.double(forKey: "bpm")
        if self.bpm < Settings.minBPM || self.bpm > Settings.maxBPM {
            self.bpm = Settings.defaultBPM
        }
        
        if let savedModeRawValue = UserDefaults.standard.string(forKey: "trainingMode"),
           let savedMode = TrainingMode(rawValue: savedModeRawValue) {
            self.trainingMode = savedMode
        } else {
            self.trainingMode = .tap
        }
        
        self.hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
        if !UserDefaults.standard.object(forKey: "hapticFeedbackEnabled").map({ _ in true }) ?? false {
            // If setting doesn't exist yet, default to enabled
            self.hapticFeedbackEnabled = true
        }
    }
    
    // MARK: - Methods
    func resetToDefaults() {
        bpm = Settings.defaultBPM
        trainingMode = .tap
        hapticFeedbackEnabled = true
    }
}
