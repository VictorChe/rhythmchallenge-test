import SwiftUI

struct MetronomeVisualizer: View {
    @ObservedObject var viewModel: MetronomeViewModel
    let beatsPerMeasure: Int = 4
    
    var body: some View {
        VStack(spacing: 16) {
            // Visual metronome
            HStack(spacing: 12) {
                ForEach(0..<beatsPerMeasure, id: \.self) { beatIndex in
                    BeatIndicator(
                        isActive: viewModel.isRunning && viewModel.currentBeat % beatsPerMeasure == beatIndex,
                        isAccented: beatIndex == 0,
                        isCountingDown: viewModel.isCountingDown
                    )
                    .animation(.easeInOut(duration: 0.1), value: viewModel.currentBeat)
                }
            }
            .padding()
            
            // Countdown indicator
            if viewModel.isCountingDown {
                Text("Get Ready: \(viewModel.countdownCount)")
                    .font(.title)
                    .foregroundColor(AppColor.accent)
                    .padding()
                    .animation(.easeInOut, value: viewModel.countdownCount)
            }
            
            // Controls
            HStack(spacing: 24) {
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.stopMetronome()
                    } else {
                        viewModel.startMetronome()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(viewModel.isRunning ? .red : AppColor.accent)
                }
            }
            .padding()
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
}

struct BeatIndicator: View {
    let isActive: Bool
    let isAccented: Bool
    let isCountingDown: Bool
    
    var body: some View {
        Circle()
            .fill(fillColor)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(isAccented ? AppColor.accent : AppColor.secondaryText, lineWidth: isAccented ? 2 : 1)
            )
            .scaleEffect(isActive ? 1.3 : 1.0)
            .shadow(color: isActive ? AppColor.accent.opacity(0.6) : Color.clear, radius: 5)
    }
    
    private var fillColor: Color {
        if isActive {
            return isCountingDown ? .orange : AppColor.accent
        } else {
            return isAccented ? AppColor.accent.opacity(0.2) : Color.clear
        }
    }
}