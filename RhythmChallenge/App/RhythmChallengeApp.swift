// RhythmChallengeApp.swift
// Simplified console version of the Rhythm Challenge app

import Foundation

// Constants
let defaultBPM = 90.0
let metronomeSoundSymbol = "♪"
let accentedBeatSymbol = "♫"

// Rhythm patterns
enum Pattern: String, CaseIterable {
    case quarter = "Quarter Notes (1, 2, 3, 4)"
    case eighth = "Eighth Notes (1 & 2 & 3 & 4 &)"
    case triplet = "Triplets (1-trip-let, 2-trip-let, 3-trip-let, 4-trip-let)"
    
    var subdivisions: Int {
        switch self {
        case .quarter: return 1
        case .eighth: return 2
        case .triplet: return 3
        }
    }
    
    var description: String {
        return self.rawValue
    }
}

// Simple metronome implementation
class Metronome {
    var bpm: Double
    var isRunning = false
    var pattern: Pattern
    var beat = 0
    var timer: Timer?
    
    init(bpm: Double = defaultBPM, pattern: Pattern = .quarter) {
        self.bpm = bpm
        self.pattern = pattern
    }
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        beat = 0
        
        // Calculate interval based on BPM and pattern
        let beatInterval = 60.0 / (bpm * Double(pattern.subdivisions))
        
        // Set up timer
        timer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func tick() {
        // Calculate whether this is a main beat or subdivision
        let isMainBeat = beat % pattern.subdivisions == 0
        let isFirstBeat = beat == 0
        
        // Print different symbols for different beats
        if isFirstBeat {
            print("\(accentedBeatSymbol) ", terminator: "")
        } else if isMainBeat {
            print("\(metronomeSoundSymbol) ", terminator: "")
        } else {
            print(". ", terminator: "")
        }
        
        // Flush output to ensure immediate display
        fflush(stdout)
        
        // Increment beat counter, cycling through a measure
        beat = (beat + 1) % (4 * pattern.subdivisions)
        
        // If we completed a measure, print a newline
        if beat == 0 {
            print("")
        }
    }
    
    func setBPM(_ newBPM: Double) {
        let wasRunning = isRunning
        
        if wasRunning {
            stop()
        }
        
        bpm = max(40, min(newBPM, 240))
        
        if wasRunning {
            start()
        }
    }
    
    func setPattern(_ newPattern: Pattern) {
        let wasRunning = isRunning
        
        if wasRunning {
            stop()
        }
        
        pattern = newPattern
        
        if wasRunning {
            start()
        }
    }
}

// Main application controller
class RhythmChallengeApp {
    let metronome = Metronome()
    var isRunning = false
    
    func run() {
        printWelcomeMessage()
        
        // Set up signal handler for clean exit
        signal(SIGINT) { _ in
            print("\nExiting Rhythm Challenge...")
            exit(0)
        }
        
        // Main menu loop
        while true {
            printMainMenu()
            handleMainMenuInput()
        }
    }
    
    func printWelcomeMessage() {
        print("===================================")
        print("Welcome to Rhythm Challenge!")
        print("A metronome and rhythm training app")
        print("===================================")
        print("")
    }
    
    func printMainMenu() {
        print("\nMAIN MENU:")
        print("1. Start/Stop Metronome")
        print("2. Adjust BPM (current: \(Int(metronome.bpm)))")
        print("3. Change Rhythm Pattern (current: \(metronome.pattern.description))")
        print("4. Exit")
        print("\nEnter your choice (1-4): ", terminator: "")
    }
    
    func handleMainMenuInput() {
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("Invalid input. Please try again.")
            return
        }
        
        switch input {
        case "1":
            toggleMetronome()
        case "2":
            adjustBPM()
        case "3":
            changePattern()
        case "4":
            print("Thank you for using Rhythm Challenge!")
            exit(0)
        default:
            print("Invalid choice. Please enter a number between 1 and 4.")
        }
    }
    
    func toggleMetronome() {
        if metronome.isRunning {
            metronome.stop()
            print("\nMetronome stopped.")
        } else {
            print("\nStarting metronome at \(Int(metronome.bpm)) BPM...")
            metronome.start()
        }
    }
    
    func adjustBPM() {
        print("\nCurrent BPM: \(Int(metronome.bpm))")
        print("Enter new BPM (40-240): ", terminator: "")
        
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
              let newBPM = Double(input) else {
            print("Invalid input. BPM unchanged.")
            return
        }
        
        metronome.setBPM(newBPM)
        print("BPM set to \(Int(metronome.bpm)).")
    }
    
    func changePattern() {
        print("\nSelect rhythm pattern:")
        
        for (index, pattern) in Pattern.allCases.enumerated() {
            print("\(index + 1). \(pattern.description)")
        }
        
        print("\nEnter pattern number: ", terminator: "")
        
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
              let selection = Int(input),
              selection >= 1 && selection <= Pattern.allCases.count else {
            print("Invalid input. Pattern unchanged.")
            return
        }
        
        let selectedPattern = Pattern.allCases[selection - 1]
        metronome.setPattern(selectedPattern)
        print("Pattern set to: \(selectedPattern.description)")
    }
}

// Start the application
let app = RhythmChallengeApp()
app.run()