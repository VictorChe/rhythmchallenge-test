import Foundation
import AVFoundation
import Combine

class AudioCaptureService {
    // MARK: - Publishers
    let onsetDetected = PassthroughSubject<TimeInterval, Never>()
    
    // MARK: - Private properties
    private var audioEngine: AVAudioEngine
    private var inputNode: AVAudioInputNode
    private var analyzer: AudioAnalyzer
    private var isRunning = false
    
    // Onset detection parameters
    private let onsetThreshold: Float = 0.1
    private let minimumTimeBetweenOnsets: TimeInterval = 0.05 // 50ms
    private var lastOnsetTime: TimeInterval = 0
    
    // MARK: - Initialization
    init() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
        analyzer = AudioAnalyzer()
        
        setupAudioSession()
    }
    
    deinit {
        stopCapture()
    }
    
    // MARK: - Public methods
    func startCapture() {
        guard !isRunning else { return }
        
        // Set up tap on input node
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 512, format: format) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer, time: time)
        }
        
        do {
            try audioEngine.start()
            isRunning = true
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    func stopCapture() {
        guard isRunning else { return }
        
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isRunning = false
    }
    
    // MARK: - Private methods
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Extract amplitude from buffer
        guard let channelData = buffer.floatChannelData else { return }
        
        let frameCount = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        // Process only first channel for simplicity
        var maxAmplitude: Float = 0
        
        for frame in 0..<frameCount {
            let amplitude = abs(channelData[0][frame])
            maxAmplitude = max(maxAmplitude, amplitude)
        }
        
        // Detect onset
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        if maxAmplitude > onsetThreshold && 
           (currentTime - lastOnsetTime) > minimumTimeBetweenOnsets {
            lastOnsetTime = currentTime
            
            // Apply additional analysis if needed
            let isValidOnset = analyzer.isValidOnset(amplitude: maxAmplitude, buffer: buffer)
            
            if isValidOnset {
                // Publish the onset detection
                DispatchQueue.main.async { [weak self] in
                    self?.onsetDetected.send(currentTime)
                }
            }
        }
    }
}