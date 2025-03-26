// main.swift
// Entry point for the RhythmChallenge console application

import Foundation

// Define available modes
enum AppMode: String, CaseIterable {
    case metronome = "Simple Metronome"
    case audioMetronome = "Audio Metronome"
    case rhythmTrainer = "Rhythm Trainer"
    case exit = "Exit"
    
    var description: String {
        switch self {
        case .metronome:
            return "Basic metronome with visual beats"
        case .audioMetronome:
            return "Metronome with audio clicks"
        case .rhythmTrainer:
            return "Practice your rhythm skills"
        case .exit:
            return "Exit the application"
        }
    }
}

// Main class to handle application flow
class RhythmChallengeConsoleApp {
    func run() {
        printWelcomeMessage()
        
        // Main menu loop
        var running = true
        while running {
            let selectedMode = promptForMode()
            
            switch selectedMode {
            case .metronome:
                runMetronome()
            case .audioMetronome:
                runAudioMetronome()
            case .rhythmTrainer:
                runRhythmTrainer()
            case .exit:
                running = false
                printExitMessage()
            }
        }
    }
    
    private func printWelcomeMessage() {
        print("========================================")
        print("Welcome to Rhythm Challenge")
        print("A console-based metronome and rhythm trainer")
        print("========================================")
        print("")
    }
    
    private func printExitMessage() {
        print("\nThank you for using Rhythm Challenge!")
        print("Goodbye!")
    }
    
    private func promptForMode() -> AppMode {
        print("\nPlease select a mode:")
        
        for (index, mode) in AppMode.allCases.enumerated() {
            print("\(index + 1). \(mode.rawValue) - \(mode.description)")
        }
        
        print("\nEnter your choice (1-\(AppMode.allCases.count)): ", terminator: "")
        
        while true {
            if let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
               let choice = Int(input),
               choice >= 1 && choice <= AppMode.allCases.count {
                return AppMode.allCases[choice - 1]
            } else {
                print("Invalid choice. Please enter a number between 1 and \(AppMode.allCases.count): ", terminator: "")
            }
        }
    }
    
    private func runMetronome() {
        let app = RhythmChallengeApp()
        app.run()
    }
    
    private func runAudioMetronome() {
        runAudioMetronome()
    }
    
    private func runRhythmTrainer() {
        let app = ConsoleRhythmTrainerApp()
        app.run()
    }
}

// Start the application
let app = RhythmChallengeConsoleApp()
app.run()