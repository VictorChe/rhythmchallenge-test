import SwiftUI

struct MetronomeView: View {
    @EnvironmentObject var viewModel: MetronomeViewModel
    @State private var isPresentingSettings = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Title
                Text("Метроном")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // BPM Display
                BPMControlView(
                    bpm: $viewModel.settings.bpm,
                    minBPM: Settings.minBPM,
                    maxBPM: Settings.maxBPM,
                    onIncrement: { viewModel.incrementBPM() },
                    onDecrement: { viewModel.decrementBPM() }
                )
                
                Spacer()
                
                // Metronome Visual
                MetronomeVisualView(
                    isRunning: viewModel.isRunning, 
                    currentBeat: viewModel.currentBeat,
                    isCountingDown: viewModel.isCountingDown,
                    countdownValue: viewModel.countdownValue
                )
                
                Spacer()
                
                // Controls
                HStack(spacing: 50) {
                    Button(action: viewModel.resetMetronome) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: viewModel.toggleMetronome) {
                        Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: { isPresentingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsView(settings: viewModel.settings)
        }
    }
}

struct MetronomeVisualView: View {
    let isRunning: Bool
    let currentBeat: Int
    let isCountingDown: Bool
    let countdownValue: Int
    
    // For the pendulum animation
    @State private var pendulumRotation: Double = -30
    
    var body: some View {
        ZStack {
            // Metronome body
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 240, height: 300)
            
            if isCountingDown {
                // Countdown display
                Text("\(countdownValue)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            } else {
                // Pendulum
                VStack {
                    // Pendulum arm
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 200)
                        .offset(y: 80)
                    
                    // Pendulum weight
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                        .offset(y: -30)
                }
                .rotationEffect(.degrees(pendulumRotation))
                .animation(
                    isRunning ?
                        Animation.easeInOut(duration: 60/Double(max(1, Int(viewModel.settings.bpm))))
                            .repeatForever(autoreverses: true) :
                        .default,
                    value: pendulumRotation
                )
                .onAppear {
                    if isRunning {
                        pendulumRotation = 30
                    }
                }
                .onChange(of: isRunning) { newValue in
                    if newValue {
                        withAnimation {
                            pendulumRotation = 30
                        }
                    } else {
                        withAnimation {
                            pendulumRotation = -30
                        }
                    }
                }
                
                // Beat indicators
                HStack(spacing: 40) {
                    ForEach(1...4, id: \.self) { beat in
                        Circle()
                            .fill(beat == currentBeat % 4 + 1 ? Color.blue : Color.gray.opacity(0.5))
                            .frame(width: 20, height: 20)
                    }
                }
                .offset(y: 120)
            }
        }
    }
    
    private var viewModel: MetronomeViewModel {
        return MetronomeViewModel()
    }
}

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Настройки метронома")) {
                    Toggle("Вибрация", isOn: $settings.hapticFeedbackEnabled)
                }
                
                Section(header: Text("Режим тренировки")) {
                    Picker("Режим", selection: $settings.trainingMode) {
                        ForEach(Settings.TrainingMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Сбросить настройки") {
                        settings.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
            .environmentObject(MetronomeViewModel())
            .preferredColorScheme(.dark)
    }
}
