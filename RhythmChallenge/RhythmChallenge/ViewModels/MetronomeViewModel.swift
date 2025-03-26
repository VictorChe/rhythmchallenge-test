import Foundation
import Combine

class MetronomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var bpm: Double = AudioConstants.defaultBPM
    @Published var currentBeat: Int = 0
    @Published var isRunning: Bool = false
    @Published var isCountingDown: Bool = false
    @Published var countdownCount: Int = 4
    @Published var selectedPattern: RhythmPattern = RhythmPattern.quarterNotes()
    @Published var patternOptions: [RhythmPattern] = []
    
    // MARK: - Private properties
    private let metronomeService: MetronomeService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(metronomeService: MetronomeService = MetronomeService()) {
        self.metronomeService = metronomeService
        setupPatternOptions()
        setupSubscriptions()
    }
    
    // MARK: - Public methods
    func startMetronome() {
        metronomeService.start(bpm: bpm)
    }
    
    func stopMetronome() {
        metronomeService.stop()
    }
    
    func increaseBPM() {
        adjustBPM(by: 1)
    }
    
    func decreaseBPM() {
        adjustBPM(by: -1)
    }
    
    func largeBPMIncrease() {
        adjustBPM(by: 5)
    }
    
    func largeBPMDecrease() {
        adjustBPM(by: -5)
    }
    
    func setBPM(_ newBPM: Double) {
        let clampedBPM = max(AudioConstants.minBPM, min(newBPM, AudioConstants.maxBPM))
        bpm = clampedBPM
        
        if isRunning {
            metronomeService.updateBPM(clampedBPM)
        }
    }
    
    func selectPattern(_ pattern: RhythmPattern) {
        selectedPattern = pattern
    }
    
    // MARK: - Private methods
    private func setupPatternOptions() {
        patternOptions = [
            .quarterNotes(),
            .eighthPairs(),
            .triplets(),
            .sixteenthNotes(),
            .syncopated(),
            .quarterRest(),
            .eighthRest()
        ]
    }
    
    private func setupSubscriptions() {
        // Subscribe to metronome service events
        metronomeService.beatPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] beat in
                self?.currentBeat = beat
            }
            .store(in: &cancellables)
        
        metronomeService.isRunningPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRunning in
                self?.isRunning = isRunning
            }
            .store(in: &cancellables)
        
        metronomeService.isCountingDownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCountingDown in
                self?.isCountingDown = isCountingDown
            }
            .store(in: &cancellables)
        
        metronomeService.countdownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.countdownCount = count
            }
            .store(in: &cancellables)
    }
    
    private func adjustBPM(by amount: Double) {
        setBPM(bpm + amount)
    }
}