import SwiftUI

// MARK: - UI Constants
struct AppColor {
    static let background = Color.black
    static let accent = Color.blue
    static let secondaryAccent = Color.purple
    static let text = Color.white
    static let secondaryText = Color.gray
    
    // Accuracy colors
    static let accuracyPerfect = Color("AccuracyGreen", defaultColor: .green)
    static let accuracyGood = Color("AccuracyBlue", defaultColor: .blue)
    static let accuracyInaccurate = Color("AccuracyYellow", defaultColor: .yellow)
    static let accuracyMiss = Color("AccuracyRed", defaultColor: .red)
}

struct AppDimension {
    static let cornerRadius: CGFloat = 12
    static let standardPadding: CGFloat = 16
    static let buttonHeight: CGFloat = 50
}

// MARK: - Audio Constants
struct AudioConstants {
    // Metronome
    static let defaultBPM: Double = 90
    static let minBPM: Double = 40
    static let maxBPM: Double = 160
    
    // Onset detection
    static let onsetThreshold: Float = 0.1
    static let minimumTimeBetweenOnsets: TimeInterval = 0.05 // 50ms
    
    // Accuracy thresholds (as percentage of beat interval)
    static let perfectThreshold: Double = 0.15  // ±15%
    static let goodThreshold: Double = 0.30     // ±30%
    static let inaccurateThreshold: Double = 0.50 // ±50%
}

// MARK: - Application Constants
struct AppConstants {
    // Features
    static let supportedRhythmPatterns = [
        RhythmPatternType.quarterNotes,
        RhythmPatternType.eighthPairs,
        RhythmPatternType.triplets,
        RhythmPatternType.quarterRest
    ]
    
    // Training
    static let countdownBeats = 4
    static let defaultTrainingDuration: TimeInterval = 60 // 1 minute
    static let measureBeats = 4 // 4 beats per measure
}