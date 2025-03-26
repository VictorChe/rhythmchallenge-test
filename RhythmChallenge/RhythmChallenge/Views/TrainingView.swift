import SwiftUI

struct TrainingView: View {
    @ObservedObject var viewModel: RhythmTrainingViewModel
    @State private var showingSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Rhythm Training")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.text)
                    .padding(.top)
                
                // Training visualizer
                TrainingVisualizer(viewModel: viewModel)
                
                // Only show settings when not in training mode
                if viewModel.state == .idle || viewModel.state == .completed {
                    VStack(spacing: 20) {
                        // BPM Control
                        BPMControl(bpm: $viewModel.bpm)
                        
                        // Pattern Selector
                        PatternSelector(
                            selectedPattern: $viewModel.selectedPattern,
                            patterns: viewModel.patternOptions,
                            onPatternSelected: { pattern in
                                // No additional action needed since we're using a binding
                            }
                        )
                        
                        // Duration selector
                        VStack(spacing: 12) {
                            Text("Training Duration")
                                .font(.headline)
                                .foregroundColor(AppColor.text)
                            
                            HStack(spacing: 12) {
                                durationButton(seconds: 30, isSelected: viewModel.trainingDuration == 30)
                                durationButton(seconds: 60, isSelected: viewModel.trainingDuration == 60)
                                durationButton(seconds: 120, isSelected: viewModel.trainingDuration == 120)
                                durationButton(seconds: 300, isSelected: viewModel.trainingDuration == 300)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                // Show results if training is completed
                if viewModel.state == .completed, let result = viewModel.lastResult {
                    resultSummary(result)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func durationButton(seconds: TimeInterval, isSelected: Bool) -> some View {
        Button(action: {
            viewModel.setTrainingDuration(seconds)
        }) {
            VStack {
                Text(formatDuration(seconds))
                    .font(.headline)
                Text("min")
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? AppColor.accent : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : AppColor.text)
            .cornerRadius(8)
        }
    }
    
    private func resultSummary(_ result: TrainingResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Results")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColor.text)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    resultRow(label: "Overall Grade:", value: result.grade)
                    resultRow(label: "Accuracy:", value: "\(String(format: "%.1f%%", result.averageAccuracy))")
                    resultRow(label: "Average Deviation:", value: "\(String(format: "%.1f", result.averageDeviation))ms")
                }
                
                Spacer()
                
                // Grade circle
                ZStack {
                    Circle()
                        .fill(gradeColor(for: result.grade))
                        .frame(width: 80, height: 80)
                    
                    Text(result.grade)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Beat statistics
            HStack(spacing: 16) {
                statItem(count: result.perfectCount, label: "Perfect", color: AppColor.accuracyPerfect)
                statItem(count: result.goodCount, label: "Good", color: AppColor.accuracyGood)
                statItem(count: result.inaccurateCount, label: "Off", color: AppColor.accuracyInaccurate)
                statItem(count: result.missCount, label: "Miss", color: AppColor.accuracyMiss)
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColor.secondaryText)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppColor.text)
        }
    }
    
    private func statItem(count: Int, label: String, color: Color) -> some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(AppColor.secondaryText)
        }
        .frame(minWidth: 60)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = seconds / 60
        return String(format: "%.1f", minutes)
    }
    
    private func gradeColor(for grade: String) -> Color {
        switch grade.prefix(1) {
        case "A": return AppColor.accuracyPerfect
        case "B": return AppColor.accuracyGood
        case "C": return AppColor.accuracyInaccurate
        default: return AppColor.accuracyMiss
        }
    }
}