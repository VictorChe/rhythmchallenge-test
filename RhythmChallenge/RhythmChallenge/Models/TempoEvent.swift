import Foundation

struct TempoEvent: Identifiable, Equatable {
    let id = UUID()
    let timeInSeconds: Double
    let isAccent: Bool
    let isRest: Bool
    
    init(timeInSeconds: Double, isAccent: Bool = false, isRest: Bool = false) {
        self.timeInSeconds = timeInSeconds
        self.isAccent = isAccent
        self.isRest = isRest
    }
}