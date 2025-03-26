import Foundation
import Combine

class ResultsViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var results: [TrainingResult] = []
    @Published var currentResult: TrainingResult?
    @Published var showingResults = false
    
    // MARK: - Public methods
    func saveResult(_ result: TrainingResult) {
        // Only save meaningful results (at least 10 seconds of training)
        if result.duration >= 10 {
            results.append(result)
            currentResult = result
            showingResults = true
        }
    }
    
    func clearResults() {
        results.removeAll()
    }
    
    // MARK: - Computed properties
    var averageAccuracy: Double {
        guard !results.isEmpty else { return 0 }
        let sum = results.reduce(0) { $0 + $1.accuracyPercentage }
        return sum / Double(results.count)
    }
    
    var bestResult: TrainingResult? {
        results.max(by: { $0.accuracyPercentage < $1.accuracyPercentage })
    }
    
    var totalTrainingTime: TimeInterval {
        results.reduce(0) { $0 + $1.duration }
    }
    
    var formattedTotalTime: String {
        let totalSeconds = Int(totalTrainingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
