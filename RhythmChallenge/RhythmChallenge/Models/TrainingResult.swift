import Foundation

/// Represents the accuracy of a single beat
enum AccuracyLevel: String, CaseIterable {
    case perfect = "Perfect"
    case good = "Good"
    case inaccurate = "Inaccurate"
    case miss = "Miss"
    
    /// Get color name for this accuracy level
    var colorName: String {
        switch self {
        case .perfect:
            return "AccuracyGreen"
        case .good:
            return "AccuracyBlue"
        case .inaccurate:
            return "AccuracyYellow"
        case .miss:
            return "AccuracyRed"
        }
    }
    
    /// Get point value for this accuracy level
    var points: Int {
        switch self {
        case .perfect:
            return 100
        case .good:
            return 75
        case .inaccurate:
            return 25
        case .miss:
            return 0
        }
    }
}

/// Represents a single beat result in a training session
struct BeatResult: Identifiable {
    let id = UUID()
    let targetTime: TimeInterval
    let actualTime: TimeInterval?
    let accuracy: AccuracyLevel
    let deviation: TimeInterval
    
    init(targetTime: TimeInterval, actualTime: TimeInterval?, accuracy: AccuracyLevel, deviation: TimeInterval) {
        self.targetTime = targetTime
        self.actualTime = actualTime
        self.accuracy = accuracy
        self.deviation = deviation
    }
    
    /// Create a miss result for the given target time
    static func miss(targetTime: TimeInterval) -> BeatResult {
        return BeatResult(
            targetTime: targetTime,
            actualTime: nil,
            accuracy: .miss,
            deviation: 0
        )
    }
}

/// Represents the overall result of a training session
struct TrainingResult: Identifiable {
    let id = UUID()
    let date: Date
    let patternType: RhythmPatternType
    let bpm: Double
    let duration: TimeInterval
    let beatResults: [BeatResult]
    
    // MARK: - Computed properties
    
    /// Average accuracy as a percentage (0-100)
    var averageAccuracy: Double {
        let totalPoints = beatResults.reduce(0) { $0 + $1.accuracy.points }
        let maxPoints = beatResults.count * AccuracyLevel.perfect.points
        return (Double(totalPoints) / Double(maxPoints)) * 100.0
    }
    
    /// Average deviation in milliseconds
    var averageDeviation: Double {
        let validResults = beatResults.filter { $0.actualTime != nil }
        guard !validResults.isEmpty else { return 0 }
        
        let totalDeviation = validResults.reduce(0.0) { $0 + abs($1.deviation) }
        return (totalDeviation / Double(validResults.count)) * 1000.0 // Convert to ms
    }
    
    /// Number of perfect beats
    var perfectCount: Int {
        return beatResults.filter { $0.accuracy == .perfect }.count
    }
    
    /// Number of good beats
    var goodCount: Int {
        return beatResults.filter { $0.accuracy == .good }.count
    }
    
    /// Number of inaccurate beats
    var inaccurateCount: Int {
        return beatResults.filter { $0.accuracy == .inaccurate }.count
    }
    
    /// Number of missed beats
    var missCount: Int {
        return beatResults.filter { $0.accuracy == .miss }.count
    }
    
    /// Total number of beats
    var totalBeats: Int {
        return beatResults.count
    }
    
    /// Overall grade based on accuracy
    var grade: String {
        let accuracy = averageAccuracy
        
        switch accuracy {
        case 95...100:
            return "A+"
        case 90..<95:
            return "A"
        case 85..<90:
            return "A-"
        case 80..<85:
            return "B+"
        case 75..<80:
            return "B"
        case 70..<75:
            return "B-"
        case 65..<70:
            return "C+"
        case 60..<65:
            return "C"
        case 50..<60:
            return "D"
        default:
            return "F"
        }
    }
}