import SwiftUI

@main
struct RhythmChallengeApp: App {
    // Создаем общие экземпляры ViewModel для использования во всем приложении
    @StateObject var metronomeViewModel = MetronomeViewModel()
    @StateObject var rhythmTrainingViewModel = RhythmTrainingViewModel()
    @StateObject var resultsViewModel = ResultsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(metronomeViewModel)
                .environmentObject(rhythmTrainingViewModel)
                .environmentObject(resultsViewModel)
                .preferredColorScheme(.dark)
        }
    }
}