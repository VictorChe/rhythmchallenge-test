// ConsoleAudioMetronome.swift
// Simple audio metronome implementation for terminal

import Foundation

// Constants
let defaultBPM = 90.0

// Class to handle terminal-based audio metronome
class ConsoleAudioMetronome {
    var bpm: Double
    var isRunning = false
    var beat = 0
    var beatsPerMeasure = 4
    var timer: Timer?
    var useBeeps = true
    
    init(bpm: Double = defaultBPM) {
        self.bpm = bpm
    }
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        beat = 0
        
        // Calculate interval based on BPM
        let beatInterval = 60.0 / bpm
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        print("Metronome started at \(Int(bpm)) BPM")
        
        // Schedule a run loop to keep the program running
        RunLoop.current.run()
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        print("\nMetronome stopped.")
    }
    
    func tick() {
        let isAccented = beat == 0
        
        // Visual indicator
        if isAccented {
            print("CLICK (\(beat + 1))", terminator: "")
        } else {
            print("click (\(beat + 1))", terminator: "")
        }
        
        // Audio feedback using system beep or command
        if useBeeps {
            playBeep(isAccented)
        }
        
        // Update beat counter
        beat = (beat + 1) % beatsPerMeasure
        
        // Print newline if we've completed a measure
        if beat == 0 {
            print("\n")
        } else {
            print(" ", terminator: "")
        }
        
        // Flush output
        fflush(stdout)
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
    
    func setBeatsPerMeasure(_ beats: Int) {
        beatsPerMeasure = max(1, min(beats, 12))
        print("Beats per measure set to \(beatsPerMeasure)")
    }
    
    func playBeep(_ isAccented: Bool) {
        // Different approaches to produce sound based on platform
        #if os(macOS) || os(Linux)
        if isAccented {
            // Higher pitch for accented beat
            _ = shell("printf '\\a'")
        } else {
            // Regular beep
            _ = shell("printf '\\a'")
        }
        #else
        // Fallback using print
        print("\u{0007}", terminator: "")
        #endif
    }
    
    // Helper to run shell commands
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return output
    }
}

// Example usage
func runAudioMetronome() {
    let metronome = ConsoleAudioMetronome(bpm: 100)
    
    // Register signal handler for clean termination
    signal(SIGINT) { _ in
        print("\nStopping metronome and exiting...")
        exit(0)
    }
    
    print("Starting audio metronome at \(Int(metronome.bpm)) BPM")
    print("Press Ctrl+C to stop")
    
    metronome.start()
}

// Run the metronome if this file is executed directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("ConsoleAudioMetronome") {
    runAudioMetronome()
}