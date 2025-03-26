import SwiftUI

struct MainView: View {
    @EnvironmentObject var metronomeViewModel: MetronomeViewModel
    @EnvironmentObject var rhythmTrainingViewModel: RhythmTrainingViewModel
    @EnvironmentObject var resultsViewModel: ResultsViewModel
    
    var body: some View {
        TabView {
            MetronomeView(viewModel: metronomeViewModel)
                .tabItem {
                    Label("Метроном", systemImage: "metronome")
                }
            
            TrainingView(viewModel: rhythmTrainingViewModel)
                .tabItem {
                    Label("Тренировка", systemImage: "waveform")
                }
            
            ResultsView(viewModel: resultsViewModel)
                .tabItem {
                    Label("Результаты", systemImage: "chart.bar")
                }
        }
        .accentColor(AppColor.accent)
        .preferredColorScheme(.dark)
    }
}

// SwiftUI Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(MetronomeViewModel())
            .environmentObject(RhythmTrainingViewModel())
            .environmentObject(ResultsViewModel())
    }
}