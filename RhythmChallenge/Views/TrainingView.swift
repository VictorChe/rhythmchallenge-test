import SwiftUI

struct TrainingView: View {
    @EnvironmentObject var rhythmViewModel: RhythmTrainingViewModel
    @EnvironmentObject var metronomeViewModel: MetronomeViewModel
    @EnvironmentObject var resultsViewModel: ResultsViewModel
    
    @State private var showingCountdown = false
    @State private var feedbackOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if metronomeViewModel.isCountingDown {
                CountdownView(count: metronomeViewModel.countdownValue)
            } else {
                VStack(spacing: 30) {
                    // Title
                    Text("Тренировка ритма")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // BPM indicator
                    Text("\(Int(metronomeViewModel.settings.bpm)) BPM")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    // Current mode
                    Text(metronomeViewModel.settings.trainingMode.rawValue)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Current pattern visualization
                    PatternDisplayView(
                        currentPattern: rhythmViewModel.currentPattern,
                        nextPattern: rhythmViewModel.nextPatternPreview,
                        isHighlighted: rhythmViewModel.isTraining
                    )
                    .frame(height: 150)
                    .padding()
                    
                    // Accuracy feedback
                    if let latestHit = rhythmViewModel.latestHit {
                        Text(latestHit.accuracy.rawValue)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(latestHit.accuracy.color))
                            .opacity(feedbackOpacity)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    feedbackOpacity = 1.0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        feedbackOpacity = 0.0
                                    }
                                }
                            }
                    }
                    
                    Spacer()
                    
                    // Progress indicators
                    VStack(spacing: 10) {
                        ProgressBar(value: rhythmViewModel.trainingResult.accuracyPercentage / 100)
                            .frame(height: 20)
                        
                        Text("Точность: \(Int(rhythmViewModel.trainingResult.accuracyPercentage))%")
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    // Action button
                    Button(action: {
                        if rhythmViewModel.isTraining {
                            rhythmViewModel.stopTraining()
                            resultsViewModel.saveResult(rhythmViewModel.trainingResult)
                        } else {
                            rhythmViewModel.startTraining(settings: metronomeViewModel.settings)
                        }
                    }) {
                        Text(rhythmViewModel.isTraining ? "Завершить" : "Начать")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(rhythmViewModel.isTraining ? Color.red : Color.green)
                            .cornerRadius(30)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                
                // Tap area for tap mode
                if rhythmViewModel.isTraining && metronomeViewModel.settings.trainingMode == .tap {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            rhythmViewModel.handleTap()
                        }
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct ProgressBar: View {
    var value: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                // Progress
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(progressColor)
            }
            .cornerRadius(5)
        }
    }
    
    private var progressColor: Color {
        if value < 0.5 {
            return .red
        } else if value < 0.75 {
            return .orange
        } else if value < 0.9 {
            return .blue
        } else {
            return .green
        }
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
            .environmentObject(RhythmTrainingViewModel())
            .environmentObject(MetronomeViewModel())
            .environmentObject(ResultsViewModel())
            .preferredColorScheme(.dark)
    }
}
