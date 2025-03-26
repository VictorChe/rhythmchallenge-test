import Foundation
import AVFoundation
import Accelerate

class SpectralAnalysisService {
    // FFT setup
    private let fftSize: UInt = 1024
    private var fftSetup: FFTSetup?
    
    // Buffers for FFT
    private var realIn: DSPSplitComplex
    private var imagIn: DSPSplitComplex
    private var realOut: DSPSplitComplex
    private var imagOut: DSPSplitComplex
    
    // Window function (Hann window)
    private var window: [Float]
    
    init() {
        // Create FFT setup
        fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Double(fftSize))), FFTRadix(kFFTRadix2))
        
        // Allocate memory for FFT buffers
        let halfSize = Int(fftSize / 2)
        
        let realInStorage = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize))
        let imagInStorage = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize))
        let realOutStorage = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize))
        let imagOutStorage = UnsafeMutablePointer<Float>.allocate(capacity: Int(fftSize))
        
        realInStorage.initialize(repeating: 0, count: Int(fftSize))
        imagInStorage.initialize(repeating: 0, count: Int(fftSize))
        realOutStorage.initialize(repeating: 0, count: Int(fftSize))
        imagOutStorage.initialize(repeating: 0, count: Int(fftSize))
        
        realIn = DSPSplitComplex(realp: realInStorage, imagp: imagInStorage)
        imagIn = DSPSplitComplex(realp: imagInStorage, imagp: imagInStorage)
        realOut = DSPSplitComplex(realp: realOutStorage, imagp: imagOutStorage)
        imagOut = DSPSplitComplex(realp: imagOutStorage, imagp: imagOutStorage)
        
        // Create Hann window
        window = [Float](repeating: 0, count: Int(fftSize))
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
    }
    
    deinit {
        // Free allocated memory
        realIn.realp.deallocate()
        realIn.imagp.deallocate()
        realOut.realp.deallocate()
        realOut.imagp.deallocate()
        
        // Destroy FFT setup
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }
    
    func analyzeBuffer(_ buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData else { return [] }
        
        let frameCount = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        
        // Process only the first channel for simplicity
        let inputData = UnsafePointer<Float>(channelData[0])
        
        // Apply window function
        var windowedData = [Float](repeating: 0, count: Int(fftSize))
        
        // Copy data from input buffer and apply window
        if frameCount >= Int(fftSize) {
            vDSP_vmul(inputData, 1, window, 1, &windowedData, 1, vDSP_Length(fftSize))
        } else {
            // If buffer is smaller than FFT size, zero-pad
            vDSP_vmul(inputData, 1, window, 1, &windowedData, 1, vDSP_Length(frameCount))
        }
        
        // Prepare for FFT
        vDSP_ctoz(UnsafePointer(windowedData) as! UnsafePointer<DSPComplex>, 2, &realIn, 1, vDSP_Length(fftSize/2))
        
        // Perform FFT
        vDSP_fft_zrip(fftSetup!, &realIn, 1, vDSP_Length(log2(Double(fftSize))), FFTDirection(kFFTDirection_Forward))
        
        // Convert to magnitude spectrum
        var magnitudes = [Float](repeating: 0, count: Int(fftSize/2))
        vDSP_zvmags(&realIn, 1, &magnitudes, 1, vDSP_Length(fftSize/2))
        
        // Convert to dB scale
        var dbMagnitudes = [Float](repeating: 0, count: Int(fftSize/2))
        vDSP_vdbcon(&magnitudes, 1, [1.0], &dbMagnitudes, 1, vDSP_Length(fftSize/2), 1)
        
        return dbMagnitudes
    }
    
    func dominantFrequencies(_ buffer: AVAudioPCMBuffer, topCount: Int = 5) -> [Float] {
        let spectrum = analyzeBuffer(buffer)
        let sampleRate = Float(buffer.format.sampleRate)
        
        // Create array of (frequency, magnitude) pairs
        var frequencyMagnitudes = [(frequency: Float, magnitude: Float)]()
        
        for i in 0..<spectrum.count {
            let frequency = sampleRate * Float(i) / Float(fftSize)
            frequencyMagnitudes.append((frequency: frequency, magnitude: spectrum[i]))
        }
        
        // Sort by magnitude and get top frequencies
        let sortedFrequencies = frequencyMagnitudes.sorted { $0.magnitude > $1.magnitude }
        return Array(sortedFrequencies.prefix(topCount).map { $0.frequency })
    }
    
    func spectralCentroid(_ buffer: AVAudioPCMBuffer) -> Float {
        let spectrum = analyzeBuffer(buffer)
        let sampleRate = Float(buffer.format.sampleRate)
        
        var weightedSum: Float = 0
        var magnitudeSum: Float = 0
        
        for i in 0..<spectrum.count {
            let frequency = sampleRate * Float(i) / Float(fftSize)
            let magnitude = spectrum[i]
            
            weightedSum += frequency * magnitude
            magnitudeSum += magnitude
        }
        
        return magnitudeSum > 0 ? weightedSum / magnitudeSum : 0
    }
}
