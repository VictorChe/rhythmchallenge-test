import SwiftUI

struct MetronomeView: View {
    @ObservedObject var viewModel: MetronomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Metronome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.text)
                    .padding(.top)
                
                // Metronome Visualizer
                MetronomeVisualizer(viewModel: viewModel)
                
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
                
                Spacer()
            }
            .padding()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}