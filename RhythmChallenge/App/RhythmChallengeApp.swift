import SwiftUI
import AVFoundation

@main
struct RhythmChallengeApp: App {
    
    @StateObject private var metronomeViewModel = MetronomeViewModel()
    @StateObject private var rhythmTrainingViewModel = RhythmTrainingViewModel()
    @StateObject private var resultsViewModel = ResultsViewModel()
    
    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(metronomeViewModel)
                .environmentObject(rhythmTrainingViewModel)
                .environmentObject(resultsViewModel)
                .preferredColorScheme(.dark)
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
}
