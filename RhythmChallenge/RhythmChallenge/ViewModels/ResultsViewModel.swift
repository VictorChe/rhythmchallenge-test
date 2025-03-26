import Foundation
import Combine

class ResultsViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var trainingResults: [TrainingResult] = []
    @Published var selectedResult: TrainingResult?
    @Published var sortOption: SortOption = .dateDescending
    @Published var filterOption: FilterOption = .all
    
    // MARK: - Private properties
    private var allResults: [TrainingResult] = []
    
    // MARK: - Initialization
    init() {
        // In a real app, we would load results from persistent storage
        loadMockData()
    }
    
    // MARK: - Public methods
    func addResult(_ result: TrainingResult) {
        allResults.append(result)
        applyFilterAndSort()
    }
    
    func selectResult(_ result: TrainingResult) {
        selectedResult = result
    }
    
    func clearSelection() {
        selectedResult = nil
    }
    
    func applySortOption(_ option: SortOption) {
        sortOption = option
        applyFilterAndSort()
    }
    
    func applyFilterOption(_ option: FilterOption) {
        filterOption = option
        applyFilterAndSort()
    }
    
    func deleteResult(_ result: TrainingResult) {
        if let index = allResults.firstIndex(where: { $0.id == result.id }) {
            allResults.remove(at: index)
            
            // If we deleted the selected result, clear the selection
            if selectedResult?.id == result.id {
                selectedResult = nil
            }
            
            applyFilterAndSort()
        }
    }
    
    func clearAllResults() {
        allResults = []
        selectedResult = nil
        applyFilterAndSort()
    }
    
    // MARK: - Private methods
    private func applyFilterAndSort() {
        // First filter
        var filtered = allResults
        
        switch filterOption {
        case .all:
            // No filtering needed
            break
        case .lastWeek:
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            filtered = filtered.filter { $0.date >= oneWeekAgo }
        case .lastMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            filtered = filtered.filter { $0.date >= oneMonthAgo }
        case .pattern(let patternType):
            filtered = filtered.filter { $0.patternType == patternType }
        }
        
        // Then sort
        switch sortOption {
        case .dateAscending:
            filtered.sort { $0.date < $1.date }
        case .dateDescending:
            filtered.sort { $0.date > $1.date }
        case .accuracyAscending:
            filtered.sort { $0.averageAccuracy < $1.averageAccuracy }
        case .accuracyDescending:
            filtered.sort { $0.averageAccuracy > $1.averageAccuracy }
        case .bpmAscending:
            filtered.sort { $0.bpm < $1.bpm }
        case .bpmDescending:
            filtered.sort { $0.bpm > $1.bpm }
        }
        
        // Update published property
        trainingResults = filtered
    }
    
    private func loadMockData() {
        // In a real app, we would load from persistent storage
        // For now, we'll start with an empty list
        allResults = []
        applyFilterAndSort()
    }
    
    // MARK: - Helper types
    enum SortOption {
        case dateAscending
        case dateDescending
        case accuracyAscending
        case accuracyDescending
        case bpmAscending
        case bpmDescending
        
        var description: String {
            switch self {
            case .dateAscending:
                return "Date (Oldest First)"
            case .dateDescending:
                return "Date (Newest First)"
            case .accuracyAscending:
                return "Accuracy (Low to High)"
            case .accuracyDescending:
                return "Accuracy (High to Low)"
            case .bpmAscending:
                return "BPM (Low to High)"
            case .bpmDescending:
                return "BPM (High to Low)"
            }
        }
    }
    
    enum FilterOption: Equatable {
        case all
        case lastWeek
        case lastMonth
        case pattern(RhythmPatternType)
        
        var description: String {
            switch self {
            case .all:
                return "All Results"
            case .lastWeek:
                return "Last Week"
            case .lastMonth:
                return "Last Month"
            case .pattern(let type):
                return "Pattern: \(type.rawValue)"
            }
        }
        
        static func == (lhs: FilterOption, rhs: FilterOption) -> Bool {
            switch (lhs, rhs) {
            case (.all, .all),
                 (.lastWeek, .lastWeek),
                 (.lastMonth, .lastMonth):
                return true
            case (.pattern(let lType), .pattern(let rType)):
                return lType == rType
            default:
                return false
            }
        }
    }
}