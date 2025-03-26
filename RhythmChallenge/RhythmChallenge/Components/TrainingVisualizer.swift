import SwiftUI

struct TrainingVisualizer: View {
    @ObservedObject var viewModel: RhythmTrainingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Training state
            stateView
            
            // Visualizer
            visualizerView
                .frame(height: 100)
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
            
            // Statistics
            if viewModel.state == .training || viewModel.state == .completed {
                statisticsView
            }
            
            // Controls
            controlsView
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var stateView: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                Text("Ready to Start")
                    .font(.title)
                    .foregroundColor(AppColor.text)
                
            case .countdown:
                Text("Get Ready: \(viewModel.countdownCount)")
                    .font(.title)
                    .foregroundColor(AppColor.accent)
                    .animation(.easeInOut, value: viewModel.countdownCount)
                
            case .training:
                VStack {
                    Text("Training in Progress")
                        .font(.title)
                        .foregroundColor(AppColor.accent)
                    
                    Text(formatTime(viewModel.elapsedTime))
                        .font(.headline)
                        .foregroundColor(AppColor.secondaryText)
                }
                
            case .completed:
                Text("Training Complete!")
                    .font(.title)
                    .foregroundColor(AppColor.accent)
            }
        }
    }
    
    private var visualizerView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { measureIndex in
                HStack(spacing: 4) {
                    ForEach(0..<viewModel.selectedPattern.subdivisions * 4, id: \.self) { beatIndex in
                        let totalBeatIndex = measureIndex * viewModel.selectedPattern.subdivisions * 4 + beatIndex
                        let isMainBeat = beatIndex % viewModel.selectedPattern.subdivisions == 0
                        let isFirstBeat = beatIndex == 0
                        let isActiveBeat = viewModel.currentBeat == totalBeatIndex % (viewModel.selectedPattern.subdivisions * 4)
                        
                        Circle()
                            .fill(isActiveBeat ? AppColor.accent : Color.clear)
                            .frame(width: isMainBeat ? 16 : 10, height: isMainBeat ? 16 : 10)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isFirstBeat ? AppColor.accent : (isMainBeat ? AppColor.secondaryText : Color.gray.opacity(0.5)),
                                        lineWidth: isFirstBeat ? 2 : 1
                                    )
                            )
                            .scaleEffect(isActiveBeat ? 1.3 : 1.0)
                    }
                }
                .padding(.trailing, 8)
                
                if measureIndex < 3 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 1, height: 40)
                }
            }
        }
    }
    
    private var statisticsView: some View {
        HStack(spacing: 20) {
            statItem(count: viewModel.perfectCount, label: "Perfect", color: AppColor.accuracyPerfect)
            statItem(count: viewModel.goodCount, label: "Good", color: AppColor.accuracyGood)
            statItem(count: viewModel.inaccurateCount, label: "Off", color: AppColor.accuracyInaccurate)
            statItem(count: viewModel.missCount, label: "Miss", color: AppColor.accuracyMiss)
        }
        .padding()
    }
    
    private var controlsView: some View {
        HStack(spacing: 20) {
            if viewModel.state == .idle || viewModel.state == .completed {
                Button(action: {
                    viewModel.startTraining()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                    .padding()
                    .frame(minWidth: 120)
                    .background(AppColor.accent)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                Button(action: {
                    viewModel.stopTraining()
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .padding()
                    .frame(minWidth: 120)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func statItem(count: Int, label: String, color: Color) -> some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(AppColor.secondaryText)
        }
        .frame(width: 60)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}