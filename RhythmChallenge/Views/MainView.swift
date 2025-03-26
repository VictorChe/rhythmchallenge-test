import SwiftUI

struct MainView: View {
    @EnvironmentObject var metronomeViewModel: MetronomeViewModel
    @EnvironmentObject var rhythmTrainingViewModel: RhythmTrainingViewModel
    @EnvironmentObject var resultsViewModel: ResultsViewModel
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MetronomeView()
                .tabItem {
                    Label("Метроном", systemImage: "metronome")
                }
                .tag(0)
            
            TrainingView()
                .tabItem {
                    Label("Тренировка", systemImage: "music.note")
                }
                .tag(1)
            
            ResultsView()
                .tabItem {
                    Label("Результаты", systemImage: "chart.bar")
                }
                .tag(2)
        }
        .accentColor(Color.blue)
        .onChange(of: selectedTab) { newValue in
            if newValue != 1 && rhythmTrainingViewModel.isTraining {
                // Stop training when switching away from training tab
                rhythmTrainingViewModel.stopTraining()
                resultsViewModel.saveResult(rhythmTrainingViewModel.trainingResult)
            }
            
            // Stop metronome when switching away from metronome tab
            if newValue != 0 && metronomeViewModel.isRunning {
                metronomeViewModel.stopMetronome()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(MetronomeViewModel())
            .environmentObject(RhythmTrainingViewModel())
            .environmentObject(ResultsViewModel())
            .preferredColorScheme(.dark)
    }
}
