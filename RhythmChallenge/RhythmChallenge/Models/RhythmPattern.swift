import Foundation

/// Defines different types of rhythm patterns available in the app
enum RhythmPatternType: String, CaseIterable, Identifiable {
    case quarterNotes = "Quarter Notes"
    case eighthPairs = "Eighth Note Pairs"
    case triplets = "Triplets"
    case sixteenthNotes = "Sixteenth Notes"
    case syncopated = "Syncopated"
    case quarterRest = "Quarter Rests"
    case eighthRest = "Eighth Rests"
    case custom = "Custom"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .quarterNotes:
            return "Basic quarter notes (1, 2, 3, 4)"
        case .eighthPairs:
            return "Pairs of eighth notes (1 & 2 & 3 & 4 &)"
        case .triplets:
            return "Triplets (1-trip-let, 2-trip-let, 3-trip-let, 4-trip-let)"
        case .sixteenthNotes:
            return "Sixteenth notes (1 e & a, 2 e & a, 3 e & a, 4 e & a)"
        case .syncopated:
            return "Syncopated rhythm with accents on the off-beats"
        case .quarterRest:
            return "Pattern with quarter rests (1, -, 3, -)"
        case .eighthRest:
            return "Pattern with eighth rests (1, &, 2, -, 3, &, 4, -)"
        case .custom:
            return "Custom-defined rhythm pattern"
        }
    }
    
    var difficulty: Int {
        switch self {
        case .quarterNotes: return 1
        case .eighthPairs: return 2
        case .triplets: return 3
        case .quarterRest: return 2
        case .eighthRest: return 3
        case .sixteenthNotes: return 4
        case .syncopated: return 4
        case .custom: return 3
        }
    }
}

/// Represents a single beat in a rhythm pattern
struct Beat: Identifiable, Equatable {
    let id = UUID()
    let position: Double  // Position within measure (0.0 to 1.0)
    let accent: Bool       // Whether this beat is accented
    let isRest: Bool       // Whether this beat is a rest
    
    init(position: Double, accent: Bool = false, isRest: Bool = false) {
        self.position = position
        self.accent = accent
        self.isRest = isRest
    }
}

/// Represents a complete rhythm pattern with multiple beats
struct RhythmPattern: Identifiable {
    let id = UUID()
    let type: RhythmPatternType
    let beats: [Beat]
    let beatsPerMeasure: Int
    let subdivisions: Int     // How many subdivisions per beat
    var name: String { type.rawValue }
    
    init(type: RhythmPatternType, beats: [Beat], beatsPerMeasure: Int = 4, subdivisions: Int = 1) {
        self.type = type
        self.beats = beats
        self.beatsPerMeasure = beatsPerMeasure
        self.subdivisions = subdivisions
    }
    
    // Factory methods for creating standard patterns
    static func quarterNotes() -> RhythmPattern {
        let beats = (0..<4).map { Beat(position: Double($0) / 4.0, accent: $0 == 0) }
        return RhythmPattern(type: .quarterNotes, beats: beats)
    }
    
    static func eighthPairs() -> RhythmPattern {
        let beats = (0..<8).map { 
            Beat(position: Double($0) / 8.0, accent: $0 % 2 == 0 && $0 < 8)
        }
        return RhythmPattern(type: .eighthPairs, beats: beats, subdivisions: 2)
    }
    
    static func triplets() -> RhythmPattern {
        let beats = (0..<12).map { 
            Beat(position: Double($0) / 12.0, accent: $0 % 3 == 0)
        }
        return RhythmPattern(type: .triplets, beats: beats, subdivisions: 3)
    }
    
    static func sixteenthNotes() -> RhythmPattern {
        let beats = (0..<16).map { 
            Beat(position: Double($0) / 16.0, accent: $0 % 4 == 0)
        }
        return RhythmPattern(type: .sixteenthNotes, beats: beats, subdivisions: 4)
    }
    
    static func syncopated() -> RhythmPattern {
        // Create a syncopated pattern (accent on off-beats)
        let positions: [Double] = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
        let accents: [Bool] = [true, false, false, true, false, true, false, false]
        
        let beats = zip(positions, accents).map { Beat(position: $0, accent: $1) }
        return RhythmPattern(type: .syncopated, beats: beats, subdivisions: 2)
    }
    
    static func quarterRest() -> RhythmPattern {
        // Quarter notes with rests
        let positions: [Double] = [0.0, 0.25, 0.5, 0.75]
        let accents: [Bool] = [true, false, true, false]
        let rests: [Bool] = [false, true, false, true]
        
        let beats = zip(zip(positions, accents), rests).map { args -> Beat in
            let ((position, accent), isRest) = args
            return Beat(position: position, accent: accent, isRest: isRest)
        }
        
        return RhythmPattern(type: .quarterRest, beats: beats)
    }
    
    static func eighthRest() -> RhythmPattern {
        // Eighth notes with rests
        let positions: [Double] = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
        let accents: [Bool] = [true, false, true, false, true, false, true, false]
        let rests: [Bool] = [false, false, false, true, false, false, false, true]
        
        let beats = zip(zip(positions, accents), rests).map { args -> Beat in
            let ((position, accent), isRest) = args
            return Beat(position: position, accent: accent, isRest: isRest)
        }
        
        return RhythmPattern(type: .eighthRest, beats: beats, subdivisions: 2)
    }
    
    // Convert pattern to beats per minute for a given base BPM
    func toTempoBeats(baseBPM: Double) -> [TempoEvent] {
        return beats.map { beat in
            let beatPosition = beat.position * Double(beatsPerMeasure)
            let timeInSeconds = (beatPosition * 60.0) / baseBPM
            
            return TempoEvent(
                timeInSeconds: timeInSeconds,
                isAccent: beat.accent,
                isRest: beat.isRest
            )
        }
    }
}