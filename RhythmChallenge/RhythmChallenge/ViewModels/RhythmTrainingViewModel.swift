import Foundation
import Combine

enum TrainingState {
    case idle
    case countdown
    case training
    case completed
}

class RhythmTrainingViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var state: TrainingState = .idle
    @Published var bpm: Double = AudioConstants.defaultBPM
    @Published var currentBeat: Int = 0
    @Published var countdownCount: Int = 4
    @Published var selectedPattern: RhythmPattern = RhythmPattern.quarterNotes()
    @Published var patternOptions: [RhythmPattern] = []
    @Published var elapsedTime: TimeInterval = 0
    @Published var trainingDuration: TimeInterval = AppConstants.defaultTrainingDuration
    @Published var beatResults: [BeatResult] = []
    @Published var lastResult: TrainingResult?
    @Published var recentResults: [TrainingResult] = []
    
    // Statistics during training
    @Published var perfectCount: Int = 0
    @Published var goodCount: Int = 0
    @Published var inaccurateCount: Int = 0
    @Published var missCount: Int = 0
    
    // MARK: - Private properties
    private let metronomeService: MetronomeService
    private let audioCaptureService: AudioCaptureService
    private let timingService: TimingService
    private var cancellables = Set<AnyCancellable>()
    
    // Training variables
    private var targetBeats: [TempoEvent] = []
    private var capturedBeats: [TimeInterval] = []
    private var trainingStartTime: TimeInterval = 0
    private var timer: Timer?
    private var measureCount: Int = 0
    
    // MARK: - Initialization
    init(metronomeService: MetronomeService = MetronomeService(),
         audioCaptureService: AudioCaptureService = AudioCaptureService(),
         timingService: TimingService = TimingService()) {
        
        self.metronomeService = metronomeService
        self.audioCaptureService = audioCaptureService
        self.timingService = timingService
        
        setupPatternOptions()
        setupSubscriptions()
    }
    
    // MARK: - Public methods
    func startTraining() {
        // Reset state
        resetTrainingState()
        
        // Generate target beats from pattern
        targetBeats = selectedPattern.toTempoBeats(baseBPM: bpm)
        
        // Start countdown
        state = .countdown
        metronomeService.start(bpm: bpm)
    }
    
    func stopTraining() {
        cleanupTraining()
        state = .idle
    }
    
    func setBPM(_ newBPM: Double) {
        let clampedBPM = max(AudioConstants.minBPM, min(newBPM, AudioConstants.maxBPM))
        bpm = clampedBPM
    }
    
    func selectPattern(_ pattern: RhythmPattern) {
        selectedPattern = pattern
    }
    
    func setTrainingDuration(_ minutes: Double) {
        trainingDuration = minutes * 60
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
                self?.handleBeat(beat)
            }
            .store(in: &cancellables)
        
        metronomeService.countdownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.countdownCount = count
            }
            .store(in: &cancellables)
        
        metronomeService.countdownCompletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startActiveTraining()
            }
            .store(in: &cancellables)
        
        // Subscribe to audio capture service
        audioCaptureService.onsetDetected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timestamp in
                self?.handleOnsetDetected(at: timestamp)
            }
            .store(in: &cancellables)
    }
    
    private func startActiveTraining() {
        state = .training
        
        // Start timing
        trainingStartTime = Date.timeIntervalSinceReferenceDate
        timingService.startTiming()
        
        // Start audio capture
        audioCaptureService.startCapture()
        
        // Start timer to update elapsed time
        startElapsedTimeTimer()
    }
    
    private func handleBeat(_ beat: Int) {
        // Only process during training
        guard state == .training else { return }
        
        // Check if we've reached the training duration
        if elapsedTime >= trainingDuration {
            completeTraining()
        }
        
        // Process missed beats
        processMissedBeats()
    }
    
    private func handleOnsetDetected(at timestamp: TimeInterval) {
        // Only process during training
        guard state == .training else { return }
        
        let offsetTime = timestamp - trainingStartTime
        capturedBeats.append(offsetTime)
        
        // Process the captured beat
        processCapturedBeat(offsetTime)
    }
    
    private func processCapturedBeat(_ capturedTime: TimeInterval) {
        // Find the closest target beat
        guard let (closestBeat, index) = findClosestTargetBeat(to: capturedTime) else { return }
        
        // Calculate deviation
        let deviation = capturedTime - closestBeat.timeInSeconds
        let beatDuration = 60.0 / bpm
        let deviationPercentage = deviation / beatDuration
        
        // Determine accuracy
        let accuracy: AccuracyLevel
        if abs(deviationPercentage) <= AudioConstants.perfectThreshold {
            accuracy = .perfect
            perfectCount += 1
        } else if abs(deviationPercentage) <= AudioConstants.goodThreshold {
            accuracy = .good
            goodCount += 1
        } else if abs(deviationPercentage) <= AudioConstants.inaccurateThreshold {
            accuracy = .inaccurate
            inaccurateCount += 1
        } else {
            // Too far off, this is likely not related to this beat
            return
        }
        
        // Record the result
        let beatResult = BeatResult(
            targetTime: closestBeat.timeInSeconds,
            actualTime: capturedTime,
            accuracy: accuracy,
            deviation: deviation
        )
        
        // Update results (avoiding duplicates)
        if index < beatResults.count {
            // Only update if it's a miss or the new accuracy is better
            let existingResult = beatResults[index]
            if existingResult.accuracy == .miss || existingResult.accuracy.points < accuracy.points {
                beatResults[index] = beatResult
            }
        } else {
            // Add new result
            beatResults.append(beatResult)
        }
    }
    
    private func processMissedBeats() {
        let currentTime = elapsedTime
        
        // Check for target beats that should have occurred by now but weren't captured
        // Allow for a window of opportunity (50% of beat duration)
        let beatDuration = 60.0 / bpm
        let missWindow = beatDuration * AudioConstants.inaccurateThreshold
        
        // Find beats that should have occurred but don't have results
        for (index, targetBeat) in targetBeats.enumerated() {
            if targetBeat.timeInSeconds + missWindow < currentTime {
                // This beat should have occurred by now
                
                // Check if we already have a result for this beat
                let hasResult = index < beatResults.count && beatResults[index].actualTime != nil
                
                if !hasResult {
                    // Record a miss
                    let missResult = BeatResult.miss(targetTime: targetBeat.timeInSeconds)
                    
                    // Add to results
                    if index < beatResults.count {
                        beatResults[index] = missResult
                    } else {
                        beatResults.append(missResult)
                    }
                    
                    missCount += 1
                }
            }
        }
    }
    
    private func findClosestTargetBeat(to time: TimeInterval) -> (TempoEvent, Int)? {
        var closestIndex = -1
        var closestDistance = Double.infinity
        
        for (index, targetBeat) in targetBeats.enumerated() {
            let distance = abs(time - targetBeat.timeInSeconds)
            
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        guard closestIndex >= 0 else { return nil }
        return (targetBeats[closestIndex], closestIndex)
    }
    
    private func completeTraining() {
        // Stop all services
        cleanupTraining()
        
        // Process any remaining missed beats
        processMissedBeats()
        
        // Create training result
        let result = TrainingResult(
            date: Date(),
            patternType: selectedPattern.type,
            bpm: bpm,
            duration: elapsedTime,
            beatResults: beatResults
        )
        
        // Store result
        lastResult = result
        recentResults.append(result)
        
        // Update state
        state = .completed
    }
    
    private func resetTrainingState() {
        beatResults = []
        capturedBeats = []
        elapsedTime = 0
        
        perfectCount = 0
        goodCount = 0
        inaccurateCount = 0
        missCount = 0
    }
    
    private func cleanupTraining() {
        metronomeService.stop()
        audioCaptureService.stopCapture()
        timer?.invalidate()
        timer = nil
    }
    
    private func startElapsedTimeTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateElapsedTime()
        }
    }
    
    private func updateElapsedTime() {
        elapsedTime = Date.timeIntervalSinceReferenceDate - trainingStartTime
    }
}