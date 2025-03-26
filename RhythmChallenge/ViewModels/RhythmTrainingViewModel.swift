import Foundation
import Combine
import AVFoundation

class RhythmTrainingViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var trainingResult = TrainingResult()
    @Published var currentPattern: RhythmPattern?
    @Published var rhythmSequence = RhythmSequence.generateBasicSequence()
    @Published var isTraining = false
    @Published var latestHit: RhythmHit?
    @Published var sequenceTimestamps: [TimeInterval] = []
    @Published var nextPatternPreview: RhythmPattern?
    
    // MARK: - Private properties
    private var timingService: TimingService
    private var audioCaptureService: AudioCaptureService?
    private var hapticsService: HapticsService
    private var metronomeService: MetronomeService
    private var trainingStartTime: TimeInterval = 0
    private var latestHitTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    private var settings = Settings()
    
    // MARK: - Initialization
    init(
        timingService: TimingService = TimingService(),
        hapticsService: HapticsService = HapticsService(),
        metronomeService: MetronomeService = MetronomeService()
    ) {
        self.timingService = timingService
        self.hapticsService = hapticsService
        self.metronomeService = metronomeService
        
        // Initialize pattern
        self.currentPattern = rhythmSequence.currentPattern
        updateNextPatternPreview()
        
        // Subscribe to metronome beats
        metronomeService.beatPublisher
            .sink { [weak self] beat in
                self?.handleMetronomeBeat(beat)
            }
            .store(in: &cancellables)
        
        // Subscribe to countdown completion
        metronomeService.countdownCompletePublisher
            .sink { [weak self] _ in
                self?.startTrainingSession()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods
    func startTraining(settings: Settings) {
        self.settings = settings
        isTraining = true
        
        if settings.trainingMode == .microphone {
            setupAudioCapture()
        }
        
        // Reset the sequence
        rhythmSequence = RhythmSequence.generateBasicSequence()
        currentPattern = rhythmSequence.currentPattern
        updateNextPatternPreview()
        
        // Start metronome with countdown
        metronomeService.start(bpm: settings.bpm)
    }
    
    func stopTraining() {
        isTraining = false
        metronomeService.stop()
        audioCaptureService?.stopCapture()
        audioCaptureService = nil
        
        // Calculate final duration
        trainingResult.duration = Date.timeIntervalSinceReferenceDate - trainingStartTime
    }
    
    func handleTap() {
        guard isTraining, settings.trainingMode == .tap else { return }
        
        let tapTime = Date.timeIntervalSinceReferenceDate
        processHit(timestamp: tapTime)
    }
    
    // MARK: - Private methods
    private func startTrainingSession() {
        trainingStartTime = Date.timeIntervalSinceReferenceDate
        trainingResult = TrainingResult()
        sequenceTimestamps = []
    }
    
    private func setupAudioCapture() {
        audioCaptureService = AudioCaptureService()
        
        audioCaptureService?.onsetDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timestamp in
                self?.processHit(timestamp: timestamp)
            }
            .store(in: &cancellables)
        
        audioCaptureService?.startCapture()
    }
    
    private func handleMetronomeBeat(_ beat: Int) {
        if isTraining {
            // Calculate beat timestamp
            let now = Date.timeIntervalSinceReferenceDate
            sequenceTimestamps.append(now)
            
            // Move to next pattern if needed (typically after 4 beats)
            if beat % 4 == 0 && beat > 0 {
                moveToNextPattern()
            }
            
            // Check for missed notes in the current pattern
            if let pattern = currentPattern {
                let beatDuration = 60.0 / settings.bpm
                let currentBeatStart = now - beatDuration
                
                // For each attack in the pattern, check if it was missed
                for attackOffset in pattern.type.attackIntervals {
                    let attackTime = currentBeatStart + (attackOffset * beatDuration)
                    let threshold = beatDuration * 0.5  // 50% of beat duration as threshold
                    
                    // If the attack time is more than threshold ago and no hit was registered near it,
                    // count it as missed
                    if now - attackTime > threshold && abs(latestHitTime - attackTime) > threshold {
                        trainingResult.addMissedNote()
                    }
                }
            }
        }
    }
    
    private func moveToNextPattern() {
        rhythmSequence.moveToNextPattern()
        currentPattern = rhythmSequence.currentPattern
        updateNextPatternPreview()
    }
    
    private func updateNextPatternPreview() {
        let nextIndex = (rhythmSequence.currentIndex + 1) % rhythmSequence.patterns.count
        nextPatternPreview = rhythmSequence.patterns[nextIndex]
    }
    
    private func processHit(timestamp: TimeInterval) {
        guard let pattern = currentPattern, !sequenceTimestamps.isEmpty else { return }
        
        // Get the closest beat time
        let beatDuration = 60.0 / settings.bpm
        let currentBeatIndex = Int((timestamp - sequenceTimestamps[0]) / beatDuration)
        let currentBeatStart = sequenceTimestamps[0] + Double(currentBeatIndex) * beatDuration
        
        // Find the closest attack time in the pattern
        var closestAttackTime = currentBeatStart
        var minDeviation = Double.infinity
        
        for attackOffset in pattern.type.attackIntervals {
            let attackTime = currentBeatStart + (attackOffset * beatDuration)
            let deviation = (timestamp - attackTime) / beatDuration
            
            if abs(deviation) < abs(minDeviation) {
                minDeviation = deviation
                closestAttackTime = attackTime
            }
        }
        
        // Calculate accuracy
        let accuracy = HitAccuracy.fromDeviation(minDeviation)
        
        // Add hit to results
        trainingResult.addHit(
            timestamp: timestamp,
            accuracy: accuracy,
            patternType: pattern.type,
            targetTime: closestAttackTime,
            deviation: minDeviation
        )
        
        // Update the latest hit for UI feedback
        latestHit = trainingResult.hits.last
        latestHitTime = timestamp
        
        // Provide haptic feedback
        if settings.hapticFeedbackEnabled {
            switch accuracy {
            case .perfect:
                hapticsService.playHaptic(.success)
            case .good:
                hapticsService.playHaptic(.success)
            case .inaccurate:
                hapticsService.playHaptic(.warning)
            case .miss:
                hapticsService.playHaptic(.error)
            }
        }
    }
}
