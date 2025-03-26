import Foundation
import Combine
import AVFoundation

class MetronomeService {
    // MARK: - Publishers
    let beatPublisher = PassthroughSubject<Int, Never>()
    let countdownPublisher = PassthroughSubject<Int, Never>()
    let isCountingDownPublisher = PassthroughSubject<Bool, Never>()
    let isRunningPublisher = PassthroughSubject<Bool, Never>()
    let countdownCompletePublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Private properties
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var clickBuffer: AVAudioPCMBuffer?
    private var beatBuffer: AVAudioPCMBuffer?
    private var timer: DispatchSourceTimer?
    private var bpm: Double = 90.0
    private var currentBeat: Int = 0
    private var isRunning: Bool = false
    private var isCountingDown: Bool = false
    private var countdownCount: Int = 4
    private var lastBeatTime: UInt64 = 0
    
    // MARK: - Initialization
    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
            loadSoundBuffers()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    deinit {
        stop()
        audioEngine.stop()
    }
    
    // MARK: - Public methods
    func start(bpm: Double) {
        self.bpm = bpm
        
        // Stop any existing timer
        stopTimer()
        
        // Start countdown
        startCountdown()
    }
    
    func stop() {
        stopTimer()
        isRunning = false
        isCountingDown = false
        currentBeat = 0
        isRunningPublisher.send(false)
        isCountingDownPublisher.send(false)
        beatPublisher.send(0)
    }
    
    func updateBPM(_ newBPM: Double) {
        let wasRunning = isRunning
        
        // Stop current timer
        stopTimer()
        
        // Update BPM
        bpm = newBPM
        
        // Restart if it was running
        if wasRunning {
            startMetronome()
        }
    }
    
    // MARK: - Private methods
    private func startCountdown() {
        isCountingDown = true
        isCountingDownPublisher.send(true)
        
        countdownCount = 4
        countdownPublisher.send(countdownCount)
        
        // Use timer for countdown with the same BPM
        startTimer(for: .countdown)
    }
    
    private func startMetronome() {
        isRunning = true
        isRunningPublisher.send(true)
        currentBeat = 0
        
        // Start the high-precision timer
        startTimer(for: .metronome)
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func startTimer(for mode: TimerMode) {
        // Calculate interval in nanoseconds
        let beatInterval = 60.0 / bpm
        let intervalInSeconds = mode == .metronome ? beatInterval : beatInterval
        let intervalInNanoseconds = UInt64(intervalInSeconds * 1_000_000_000)
        
        // Create high-precision timer
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        timer.schedule(deadline: .now() + .nanoseconds(0), repeating: .nanoseconds(Int(intervalInNanoseconds)))
        
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            if mode == .countdown {
                self.handleCountdownTick()
            } else {
                self.handleMetronomeTick()
            }
        }
        
        timer.resume()
        self.timer = timer
        
        // Record start time for drift compensation
        lastBeatTime = mach_absolute_time()
    }
    
    private func handleCountdownTick() {
        // Play click sound
        playClick()
        
        // Update countdown
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.countdownCount -= 1
            self.countdownPublisher.send(self.countdownCount)
            
            if self.countdownCount <= 0 {
                // Transition to metronome mode
                self.isCountingDown = false
                self.isCountingDownPublisher.send(false)
                self.stopTimer()
                self.countdownCompletePublisher.send(())
                self.startMetronome()
            }
        }
    }
    
    private func handleMetronomeTick() {
        // Play appropriate sound
        if currentBeat % 4 == 0 {
            // Play emphasized beat (first beat in measure)
            playClick()
        } else {
            // Play regular beat
            playBeat()
        }
        
        // Update beat count
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentBeat = (self.currentBeat + 1) % 1000 // Prevent overflow
            self.beatPublisher.send(self.currentBeat)
        }
        
        // Compensate for drift
        compensateForDrift()
    }
    
    private func compensateForDrift() {
        // Calculate expected time for next beat
        let beatInterval = 60.0 / bpm
        let intervalInNanoseconds = UInt64(beatInterval * 1_000_000_000)
        
        // Get current time
        let currentTime = mach_absolute_time()
        
        // Calculate drift
        let elapsedNanoseconds = currentTime - lastBeatTime
        let driftNanoseconds = Int64(elapsedNanoseconds) - Int64(intervalInNanoseconds)
        
        // If drift is significant, adjust the next beat timing
        if abs(driftNanoseconds) > 1_000_000 { // 1ms threshold
            // Adjust the timer schedule
            timer?.schedule(
                deadline: .now() + .nanoseconds(Int(intervalInNanoseconds) - Int(driftNanoseconds)),
                repeating: .nanoseconds(Int(intervalInNanoseconds))
            )
        }
        
        // Update last beat time
        lastBeatTime = currentTime
    }
    
    private func loadSoundBuffers() {
        // In a real app, we would load actual sound files here
        // For this example, we'll create simple buffers with beep sounds
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        
        // Create click buffer (higher pitch)
        clickBuffer = createBeepBuffer(frequency: 1000, duration: 0.05, format: format)
        
        // Create beat buffer (lower pitch)
        beatBuffer = createBeepBuffer(frequency: 700, duration: 0.05, format: format)
    }
    
    private func createBeepBuffer(frequency: Float, duration: Float, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        // Calculate number of frames
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(duration * Float(sampleRate))
        
        // Create buffer
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        // Get audio buffer
        let audioBuffer = buffer.floatChannelData?[0]
        
        // Fill with sine wave
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / Float(sampleRate)
            let amplitude = sin(2.0 * .pi * frequency * time)
            
            // Apply envelope (simple fade in/out)
            let fadeTime = min(duration * 0.1, 0.01) // 10% of duration or 10ms max
            let fadeInSamples = Int(fadeTime * Float(sampleRate))
            let fadeOutSamples = Int(fadeTime * Float(sampleRate))
            
            var gain: Float = 1.0
            
            if frame < fadeInSamples {
                gain = Float(frame) / Float(fadeInSamples)
            } else if frame > (Int(frameCount) - fadeOutSamples) {
                let fadeOutPosition = Int(frameCount) - frame
                gain = Float(fadeOutPosition) / Float(fadeOutSamples)
            }
            
            audioBuffer?[frame] = amplitude * gain * 0.5 // 0.5 for volume
        }
        
        return buffer
    }
    
    private func playClick() {
        guard let buffer = clickBuffer else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
    
    private func playBeat() {
        guard let buffer = beatBuffer else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
    
    // MARK: - Helper types
    private enum TimerMode {
        case countdown
        case metronome
    }
}