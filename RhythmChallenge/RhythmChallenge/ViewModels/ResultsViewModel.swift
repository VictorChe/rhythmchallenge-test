import Foundation
import Combine

class ResultsViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var trainingResults: [TrainingResult] = []
    @Published var currentFilter: RhythmPatternType?
    
    // MARK: - Computed properties
    
    /// Results filtered by the current filter
    var filteredResults: [TrainingResult] {
        if let patternType = currentFilter {
            return trainingResults.filter { $0.patternType == patternType }
        } else {
            return trainingResults
        }
    }
    
    /// Average accuracy across all filtered results
    var averageAccuracy: Double {
        guard !filteredResults.isEmpty else { return 0 }
        let totalAccuracy = filteredResults.reduce(0.0) { $0 + $1.averageAccuracy }
        return totalAccuracy / Double(filteredResults.count)
    }
    
    /// Best grade across all filtered results
    var bestGrade: String {
        guard !filteredResults.isEmpty else { return "N/A" }
        let grades = filteredResults.map { $0.grade }
        let sortedGrades = grades.sorted { (grade1, grade2) -> Bool in
            let gradeValue: [String: Int] = [
                "A+": 12, "A": 11, "A-": 10,
                "B+": 9, "B": 8, "B-": 7,
                "C+": 6, "C": 5, "C-": 4,
                "D+": 3, "D": 2, "D-": 1,
                "F": 0
            ]
            return (gradeValue[grade1] ?? 0) > (gradeValue[grade2] ?? 0)
        }
        return sortedGrades.first ?? "N/A"
    }
    
    // MARK: - Initialization
    init() {
        loadResults()
    }
    
    // MARK: - Public methods
    
    /// Load results from storage (in a real app)
    func loadResults() {
        // In a real app, we would load from UserDefaults or Core Data
        // For now, we'll use some empty results
        trainingResults = []
    }
    
    /// Add a new training result
    func addResult(_ result: TrainingResult) {
        trainingResults.append(result)
        saveResults()
    }
    
    /// Delete a specific result
    func deleteResult(_ result: TrainingResult) {
        if let index = trainingResults.firstIndex(where: { $0.id == result.id }) {
            trainingResults.remove(at: index)
            saveResults()
        }
    }
    
    /// Clear all results
    func clearAllResults() {
        trainingResults = []
        saveResults()
    }
    
    /// Filter results by pattern type
    func filterByPatternType(_ patternType: RhythmPatternType?) {
        currentFilter = patternType
    }
    
    // MARK: - Private methods
    
    /// Save results to storage (in a real app)
    private func saveResults() {
        // In a real app, we would save to UserDefaults or Core Data
    }
}