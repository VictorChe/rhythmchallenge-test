import Foundation

enum RhythmPatternType: String, CaseIterable, Identifiable {
    case quarterNotes = "Четвертные ноты"        // Quarter notes
    case eighthPairs = "Восьмые ноты (пары)"     // Eighth note pairs
    case triplets = "Триоли"                     // Triplets
    case quarterRest = "Четвертная пауза"        // Quarter rest
    
    var id: String { self.rawValue }
    
    // Number of beats in a pattern
    var beatCount: Int {
        switch self {
        case .quarterNotes:
            return 1
        case .eighthPairs:
            return 2
        case .triplets:
            return 3
        case .quarterRest:
            return 0
        }
    }
    
    // Time intervals for each attack in a pattern, as fraction of the whole beat
    var attackIntervals: [Double] {
        switch self {
        case .quarterNotes:
            return [0.0]
        case .eighthPairs:
            return [0.0, 0.5]
        case .triplets:
            return [0.0, 0.333, 0.667]
        case .quarterRest:
            return []
        }
    }
    
    // Symbol representation for UI
    var symbol: String {
        switch self {
        case .quarterNotes:
            return "♩"
        case .eighthPairs:
            return "♪♪"
        case .triplets:
            return "3"
        case .quarterRest:
            return "𝄽"
        }
    }
}

struct RhythmPattern: Identifiable {
    let id = UUID()
    let type: RhythmPatternType
    let position: Int  // Position in the current sequence
    
    // Get time offsets for this pattern based on the BPM and position
    func attackTimesInSeconds(bpm: Double, startBeat: Int) -> [Double] {
        let beatDuration = 60.0 / bpm
        let patternStartTime = Double(startBeat) * beatDuration
        
        return type.attackIntervals.map { patternStartTime + ($0 * beatDuration) }
    }
}

struct RhythmSequence {
    var patterns: [RhythmPattern]
    var currentIndex: Int = 0
    
    var currentPattern: RhythmPattern? {
        guard currentIndex < patterns.count else { return nil }
        return patterns[currentIndex]
    }
    
    mutating func moveToNextPattern() {
        currentIndex = (currentIndex + 1) % patterns.count
    }
    
    // Generate a common rhythm sequence for practice
    static func generateBasicSequence() -> RhythmSequence {
        let patternTypes = RhythmPatternType.allCases
        var patterns = [RhythmPattern]()
        
        for (index, type) in patternTypes.enumerated() {
            patterns.append(RhythmPattern(type: type, position: index))
        }
        
        return RhythmSequence(patterns: patterns)
    }
}
