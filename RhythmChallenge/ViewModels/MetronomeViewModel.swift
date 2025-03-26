import Foundation
import Combine
import SwiftUI

class MetronomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isRunning = false
    @Published var isCountingDown = false
    @Published var countdownValue = 4
    @Published var currentBeat = 0
    @Published var settings = Settings()
    
    // MARK: - Private properties
    private var metronomeService: MetronomeService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(metronomeService: MetronomeService = MetronomeService()) {
        self.metronomeService = metronomeService
        
        // Subscribe to metronome beats
        metronomeService.beatPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] beat in
                self?.currentBeat = beat
            }
            .store(in: &cancellables)
        
        // Subscribe to countdown updates
        metronomeService.countdownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.countdownValue = count
            }
            .store(in: &cancellables)
        
        // Subscribe to countdown state
        metronomeService.isCountingDownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCountingDown in
                self?.isCountingDown = isCountingDown
            }
            .store(in: &cancellables)
        
        // Subscribe to running state
        metronomeService.isRunningPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRunning in
                self?.isRunning = isRunning
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods
    func startMetronome() {
        metronomeService.start(bpm: settings.bpm)
    }
    
    func stopMetronome() {
        metronomeService.stop()
    }
    
    func toggleMetronome() {
        if isRunning {
            stopMetronome()
        } else {
            startMetronome()
        }
    }
    
    func resetMetronome() {
        stopMetronome()
        currentBeat = 0
    }
    
    func setBPM(_ newBPM: Double) {
        let clampedBPM = max(Settings.minBPM, min(Settings.maxBPM, newBPM))
        settings.bpm = clampedBPM
        
        if isRunning {
            metronomeService.updateBPM(clampedBPM)
        }
    }
    
    func incrementBPM(by increment: Double = 1.0) {
        setBPM(settings.bpm + increment)
    }
    
    func decrementBPM(by decrement: Double = 1.0) {
        setBPM(settings.bpm - decrement)
    }
}
