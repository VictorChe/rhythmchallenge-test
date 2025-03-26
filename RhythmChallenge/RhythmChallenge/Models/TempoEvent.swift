import Foundation

/// Represents a single tempo event (beat, rest) with timing information
struct TempoEvent: Identifiable, Equatable {
    let id = UUID()
    let timeInSeconds: Double  // Time in seconds from the beginning of the pattern
    let isAccented: Bool       // Whether this beat is accented
    let isRest: Bool           // Whether this is a rest or a beat
    
    enum EventType {
        case note
        case rest
    }
    
    var type: EventType {
        isRest ? .rest : .note
    }
    
    init(timeInSeconds: Double, isAccent: Bool = false, isRest: Bool = false) {
        self.timeInSeconds = timeInSeconds
        self.isAccented = isAccent
        self.isRest = isRest
    }
    
    static func == (lhs: TempoEvent, rhs: TempoEvent) -> Bool {
        return lhs.id == rhs.id
    }
}