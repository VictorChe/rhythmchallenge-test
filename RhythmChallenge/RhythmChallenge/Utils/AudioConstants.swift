import Foundation

enum AudioConstants {
    // Metronome constants
    static let minBPM: Double = 40
    static let maxBPM: Double = 208
    static let defaultBPM: Double = 90
    
    // Tempo constants
    static let minQuarterNoteDuration: Double = 0.16  // 60 / 360 bpm
    static let maxQuarterNoteDuration: Double = 2.0   // 60 / 30 bpm
    
    // Audio analysis constants
    static let analysisWindowSize: Int = 1024
    static let analysisOverlap: Int = 512
    static let minAmplitude: Float = 0.02
    static let onsetThreshold: Float = 0.3
    
    // Timing constants (milliseconds)
    static let perfectTimingThreshold: Double = 30
    static let goodTimingThreshold: Double = 60
    static let fairTimingThreshold: Double = 100
    
    // Result score multipliers
    static let perfectScoreMultiplier: Double = 1.0
    static let goodScoreMultiplier: Double = 0.75
    static let fairScoreMultiplier: Double = 0.5
    static let missScoreMultiplier: Double = 0.0
}