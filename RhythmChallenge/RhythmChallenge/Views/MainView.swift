import SwiftUI

struct MainView: View {
    @StateObject private var metronomeViewModel = MetronomeViewModel()
    @StateObject private var trainingViewModel = RhythmTrainingViewModel()
    @StateObject private var resultsViewModel = ResultsViewModel()
    
    var body: some View {
        TabView {
            MetronomeView(viewModel: metronomeViewModel)
                .tabItem {
                    Label("Metronome", systemImage: "metronome")
                }
            
            TrainingView(viewModel: trainingViewModel)
                .tabItem {
                    Label("Training", systemImage: "waveform")
                }
            
            ResultsView(viewModel: resultsViewModel)
                .tabItem {
                    Label("Results", systemImage: "chart.bar")
                }
        }
        .accentColor(AppColor.accent)
        .preferredColorScheme(.dark)
    }
}