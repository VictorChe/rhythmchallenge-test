// ConsoleRhythmTrainer.swift
// Console-based rhythm training application

import Foundation

// Main constants
let defaultBPM = 90.0
let countdownBeats = 4
let tapSymbol = "X"
let metronomeSymbol = "•"
let accentedBeatSymbol = "○"

// Simple rhythm pattern representation
struct ConsoleRhythmPattern {
    enum PatternType: String, CaseIterable {
        case quarterNotes = "Quarter Notes"
        case eighthNotes = "Eighth Notes"
        case triplets = "Triplets"
        
        var description: String {
            switch self {
            case .quarterNotes:
                return "Regular 4/4 beat (1, 2, 3, 4)"
            case .eighthNotes:
                return "Eighth notes (1 & 2 & 3 & 4 &)"
            case .triplets:
                return "Triplets (1-trip-let, 2-trip-let, 3-trip-let, 4-trip-let)"
            }
        }
        
        var subdivisions: Int {
            switch self {
            case .quarterNotes: return 1
            case .eighthNotes: return 2
            case .triplets: return 3
            }
        }
    }
    
    let type: PatternType
    let beatsPerMeasure: Int
    let subdivisions: Int
    
    init(type: PatternType, beatsPerMeasure: Int = 4) {
        self.type = type
        self.beatsPerMeasure = beatsPerMeasure
        self.subdivisions = type.subdivisions
    }
    
    var totalBeatsPerMeasure: Int {
        return beatsPerMeasure * subdivisions
    }
    
    func isMainBeat(_ beatIndex: Int) -> Bool {
        return beatIndex % subdivisions == 0
    }
    
    func isFirstBeat(_ beatIndex: Int) -> Bool {
        return beatIndex == 0
    }
}

// Handles user input for tapping rhythm
class ConsoleTapDetector {
    private var lastTapTime: TimeInterval = 0
    private var tapTimes: [TimeInterval] = []
    
    func reset() {
        tapTimes = []
        lastTapTime = 0
    }
    
    func recordTap() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        tapTimes.append(currentTime)
        lastTapTime = currentTime
    }
    
    func getTapTimes() -> [TimeInterval] {
        return tapTimes
    }
}

// Main rhythm training class
class ConsoleRhythmTrainer {
    enum TrainingState {
        case idle
        case countdown
        case training
        case completed
    }
    
    private var bpm: Double
    private var pattern: ConsoleRhythmPattern
    private var state: TrainingState = .idle
    private var tapDetector = ConsoleTapDetector()
    private var trainingDuration: TimeInterval = 10 // seconds
    private var startTime: TimeInterval = 0
    private var timer: Timer?
    private var currentBeat = 0
    private var countdownCount = countdownBeats
    private var trainingCancelled = false
    
    // Training results
    private var expectedTaps: [TimeInterval] = []
    private var actualTaps: [TimeInterval] = []
    
    init(bpm: Double = defaultBPM, pattern: ConsoleRhythmPattern = ConsoleRhythmPattern(type: .quarterNotes)) {
        self.bpm = bpm
        self.pattern = pattern
    }
    
    func startTraining() {
        print("\nPreparing rhythm training at \(Int(bpm)) BPM with \(pattern.type.rawValue) pattern")
        print("Training will last for \(Int(trainingDuration)) seconds")
        print("Press ENTER to tap along with the rhythm")
        print("Press 'q' and ENTER to quit training")
        
        // Set up for tap detection in a separate thread
        DispatchQueue.global(qos: .userInteractive).async {
            self.listenForTaps()
        }
        
        // Start countdown
        startCountdown()
    }
    
    private func startCountdown() {
        state = .countdown
        countdownCount = countdownBeats
        print("\nCountdown:")
        
        // Create beat interval
        let countdownInterval = 60.0 / bpm
        
        timer = Timer.scheduledTimer(withTimeInterval: countdownInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            print("\(self.countdownCount)... ", terminator: "")
            fflush(stdout)
            
            self.countdownCount -= 1
            
            if self.countdownCount < 0 {
                timer.invalidate()
                self.beginTraining()
            }
        }
        
        // Keep run loop running
        RunLoop.current.run(until: Date(timeIntervalSinceNow: Double(countdownBeats) * countdownInterval + 0.1))
    }
    
    private func beginTraining() {
        state = .training
        currentBeat = 0
        startTime = Date.timeIntervalSinceReferenceDate
        tapDetector.reset()
        
        print("\nTraining started! Tap along with the rhythm:")
        
        // Generate expected tap times
        generateExpectedTapTimes()
        
        // Calculate beat interval
        let beatInterval = 60.0 / (bpm * Double(pattern.subdivisions))
        
        // Start timer for metronome clicks
        timer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] timer in
            guard let self = self, !self.trainingCancelled else {
                timer.invalidate()
                return
            }
            
            self.tick()
            
            // Check if training time is up
            let elapsed = Date.timeIntervalSinceReferenceDate - self.startTime
            if elapsed >= self.trainingDuration {
                timer.invalidate()
                self.completeTraining()
            }
        }
        
        // Keep run loop running for the duration of training
        RunLoop.current.run(until: Date(timeIntervalSinceNow: trainingDuration + 0.5))
    }
    
    private func tick() {
        let isMainBeat = pattern.isMainBeat(currentBeat)
        let isFirstBeat = pattern.isFirstBeat(currentBeat)
        
        // Print different symbols for different beats
        if isFirstBeat {
            print(accentedBeatSymbol, terminator: " ")
        } else if isMainBeat {
            print(metronomeSymbol, terminator: " ")
        } else {
            print("·", terminator: " ")
        }
        
        fflush(stdout)
        
        // Move to next beat
        currentBeat = (currentBeat + 1) % pattern.totalBeatsPerMeasure
        
        // Add line break at the end of each measure
        if currentBeat == 0 {
            print("")
        }
    }
    
    private func listenForTaps() {
        // Set terminal to raw mode to capture keystrokes immediately without waiting for newline
        // Note: This is a simplified approach and works differently on different platforms
        
        while state == .training && !trainingCancelled {
            if let input = readLine() {
                if input.lowercased() == "q" {
                    trainingCancelled = true
                    print("\nTraining cancelled!")
                    break
                } else {
                    // Record the tap
                    tapDetector.recordTap()
                    print(tapSymbol, terminator: " ")
                    fflush(stdout)
                }
            }
        }
    }
    
    private func completeTraining() {
        state = .completed
        
        // Get taps
        actualTaps = tapDetector.getTapTimes()
        
        // Analyze results
        print("\n\nTraining completed!")
        analyzeResults()
    }
    
    private func generateExpectedTapTimes() {
        expectedTaps = []
        
        // Calculate the number of expected beats
        let beatInterval = 60.0 / bpm
        let totalBeats = Int(trainingDuration / beatInterval) * pattern.beatsPerMeasure
        
        // Generate the expected tap times
        for i in 0..<totalBeats {
            let beatTime = startTime + Double(i) * beatInterval
            
            // Only add main beats (not subdivisions) as expected tap times
            if i % pattern.subdivisions == 0 {
                expectedTaps.append(beatTime)
            }
        }
    }
    
    private func analyzeResults() {
        // Convert actual taps to offsets from start time
        let tapOffsets = actualTaps.map { $0 - startTime }
        
        // Convert expected taps to offsets from start time
        let expectedOffsets = expectedTaps.map { $0 - startTime }
        
        print("\nExpected taps: \(expectedOffsets.count)")
        print("Actual taps:   \(tapOffsets.count)")
        
        // Calculate accuracy
        var perfectCount = 0
        var goodCount = 0
        var offCount = 0
        var missCount = 0
        
        // Match each expected tap with the closest actual tap
        for expectedTime in expectedOffsets {
            var closestDistance = Double.infinity
            var closestTap: TimeInterval? = nil
            
            for tapTime in tapOffsets {
                let distance = abs(tapTime - expectedTime)
                if distance < closestDistance {
                    closestDistance = distance
                    closestTap = tapTime
                }
            }
            
            // Determine accuracy based on closeness
            let beatDuration = 60.0 / bpm
            let deviationPercentage = closestDistance / beatDuration
            
            if let _ = closestTap {
                if deviationPercentage <= 0.1 {
                    perfectCount += 1
                } else if deviationPercentage <= 0.2 {
                    goodCount += 1
                } else if deviationPercentage <= 0.4 {
                    offCount += 1
                } else {
                    missCount += 1
                }
            } else {
                missCount += 1
            }
        }
        
        // Calculate average deviation
        var totalDeviation = 0.0
        var matchedTaps = 0
        
        for tapTime in tapOffsets {
            var closestDistance = Double.infinity
            
            for expectedTime in expectedOffsets {
                let distance = abs(tapTime - expectedTime)
                if distance < closestDistance {
                    closestDistance = distance
                }
            }
            
            if closestDistance < Double.infinity {
                totalDeviation += closestDistance
                matchedTaps += 1
            }
        }
        
        let averageDeviation = matchedTaps > 0 ? totalDeviation / Double(matchedTaps) * 1000 : 0 // Convert to ms
        
        // Calculate overall accuracy percentage
        let totalPoints = perfectCount * 100 + goodCount * 75 + offCount * 25
        let maxPoints = expectedOffsets.count * 100
        let accuracyPercentage = maxPoints > 0 ? Double(totalPoints) / Double(maxPoints) * 100 : 0
        
        // Display results
        print("\nRESULTS:")
        print("Perfect taps: \(perfectCount)")
        print("Good taps:    \(goodCount)")
        print("Off taps:     \(offCount)")
        print("Misses:       \(missCount)")
        print("Average deviation: \(Int(averageDeviation))ms")
        print("Overall accuracy: \(Int(accuracyPercentage))%")
        
        // Grade
        let grade: String
        switch accuracyPercentage {
        case 90...100: grade = "A"
        case 80..<90: grade = "B"
        case 70..<80: grade = "C"
        case 60..<70: grade = "D"
        default: grade = "F"
        }
        
        print("Grade: \(grade)")
    }
    
    func setBPM(_ newBPM: Double) {
        bpm = max(40, min(240, newBPM))
    }
    
    func setPattern(_ type: ConsoleRhythmPattern.PatternType) {
        pattern = ConsoleRhythmPattern(type: type)
    }
    
    func setTrainingDuration(_ seconds: TimeInterval) {
        trainingDuration = max(5, min(60, seconds))
    }
}

// Main console app to run the rhythm trainer
class ConsoleRhythmTrainerApp {
    let trainer = ConsoleRhythmTrainer()
    
    func run() {
        printWelcomeMessage()
        
        // Main menu loop
        var running = true
        while running {
            printMainMenu()
            
            if let choice = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
                switch choice {
                case "1":
                    startTraining()
                case "2":
                    changeBPM()
                case "3":
                    changePattern()
                case "4":
                    changeDuration()
                case "5":
                    running = false
                    print("Thanks for using Rhythm Trainer!")
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }
    }
    
    private func printWelcomeMessage() {
        print("===================================")
        print("Welcome to Console Rhythm Trainer!")
        print("Train your rhythm skills in the terminal")
        print("===================================")
    }
    
    private func printMainMenu() {
        print("\nMAIN MENU:")
        print("1. Start Training")
        print("2. Set BPM")
        print("3. Choose Pattern")
        print("4. Set Duration")
        print("5. Exit")
        print("\nEnter your choice (1-5): ", terminator: "")
        fflush(stdout)
    }
    
    private func startTraining() {
        trainer.startTraining()
    }
    
    private func changeBPM() {
        print("\nEnter BPM (40-240): ", terminator: "")
        fflush(stdout)
        
        if let input = readLine(), let bpm = Double(input) {
            trainer.setBPM(bpm)
            print("BPM set successfully.")
        } else {
            print("Invalid input. BPM unchanged.")
        }
    }
    
    private func changePattern() {
        print("\nSelect rhythm pattern:")
        
        for (index, pattern) in ConsoleRhythmPattern.PatternType.allCases.enumerated() {
            print("\(index + 1). \(pattern.rawValue) - \(pattern.description)")
        }
        
        print("\nEnter pattern number: ", terminator: "")
        fflush(stdout)
        
        if let input = readLine(), let choice = Int(input),
           choice >= 1 && choice <= ConsoleRhythmPattern.PatternType.allCases.count {
            let patternType = ConsoleRhythmPattern.PatternType.allCases[choice - 1]
            trainer.setPattern(patternType)
            print("Pattern set to: \(patternType.rawValue)")
        } else {
            print("Invalid input. Pattern unchanged.")
        }
    }
    
    private func changeDuration() {
        print("\nEnter training duration in seconds (5-60): ", terminator: "")
        fflush(stdout)
        
        if let input = readLine(), let duration = Double(input) {
            trainer.setTrainingDuration(duration)
            print("Training duration set to \(Int(duration)) seconds.")
        } else {
            print("Invalid input. Duration unchanged.")
        }
    }
}

// Run the trainer if this file is executed directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("ConsoleRhythmTrainer") {
    let app = ConsoleRhythmTrainerApp()
    app.run()
}