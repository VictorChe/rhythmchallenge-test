import Foundation

enum HitAccuracy: String {
    case perfect = "Идеально"
    case good = "Хорошо"
    case inaccurate = "Неточно"
    case miss = "Мимо"
    
    var color: String {
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
    
    static func fromDeviation(_ deviation: Double) -> HitAccuracy {
        let absDeviation = abs(deviation)
        if absDeviation <= 0.15 {
            return .perfect
        } else if absDeviation <= 0.30 {
            return .good
        } else if absDeviation <= 0.50 {
            return .inaccurate
        } else {
            return .miss
        }
    }
}

struct RhythmHit: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let accuracy: HitAccuracy
    let patternType: RhythmPatternType
    let targetTime: TimeInterval
    let deviation: Double  // Deviation as a percentage of the beat duration
}

struct TrainingResult {
    var duration: TimeInterval = 0
    var hits = [RhythmHit]()
    var missedNotes = 0
    
    var perfectHits: Int {
        hits.filter { $0.accuracy == .perfect }.count
    }
    
    var goodHits: Int {
        hits.filter { $0.accuracy == .good }.count
    }
    
    var inaccurateHits: Int {
        hits.filter { $0.accuracy == .inaccurate }.count
    }
    
    var missedHits: Int {
        hits.filter { $0.accuracy == .miss }.count + missedNotes
    }
    
    var totalAttempted: Int {
        hits.count + missedNotes
    }
    
    var accuracyPercentage: Double {
        guard totalAttempted > 0 else { return 0 }
        
        let weightedSum = Double(perfectHits * 100 + goodHits * 75)
        return min(100, max(0, weightedSum / Double(totalAttempted)))
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Add a hit to the result
    mutating func addHit(timestamp: TimeInterval, accuracy: HitAccuracy, patternType: RhythmPatternType, targetTime: TimeInterval, deviation: Double) {
        let hit = RhythmHit(
            timestamp: timestamp,
            accuracy: accuracy,
            patternType: patternType,
            targetTime: targetTime,
            deviation: deviation
        )
        hits.append(hit)
    }
    
    // Add missed notes
    mutating func addMissedNote() {
        missedNotes += 1
    }
}
