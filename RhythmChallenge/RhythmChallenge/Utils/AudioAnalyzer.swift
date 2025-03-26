import Foundation
import AVFoundation
import Accelerate

class AudioAnalyzer {
    // MARK: - Properties
    private let spectralAnalysisService: SpectralAnalysisService
    
    // Onset detection parameters
    private let onsetThreshold: Float = 0.1 // Adjust based on testing
    private let noiseFloor: Float = 0.02    // Noise floor threshold
    
    // Calibration data
    private var calibratedSpectrum: [Float]?
    private var instrumentProfile: [Float]?
    
    // MARK: - Initialization
    init() {
        spectralAnalysisService = SpectralAnalysisService()
    }
    
    // MARK: - Public methods
    
    // Main method to determine if an audio event is a valid rhythmic onset
    func isValidOnset(amplitude: Float, buffer: AVAudioPCMBuffer) -> Bool {
        // Basic amplitude check
        if amplitude < onsetThreshold {
            return false
        }
        
        // Get spectral information
        let dominantFreqs = spectralAnalysisService.dominantFrequencies(buffer)
        let centroid = spectralAnalysisService.spectralCentroid(buffer)
        
        // Check if spectral profile matches instrument (if calibrated)
        if let profile = instrumentProfile {
            let currentSpectrum = spectralAnalysisService.analyzeBuffer(buffer)
            let similarity = calculateSpectralSimilarity(profile, currentSpectrum)
            
            // If similarity is too low, it might be noise or another sound
            if similarity < 0.6 { // 60% similarity threshold
                return false
            }
        }
        
        // Additional checks could include:
        // 1. Sudden increase in energy
        // 2. Changes in spectral flux
        // 3. Temporal pattern analysis
        
        return true
    }
    
    // Calibrate the analyzer with a sample of the instrument
    func calibrateWithSample(_ buffer: AVAudioPCMBuffer) {
        instrumentProfile = spectralAnalysisService.analyzeBuffer(buffer)
    }
    
    // Reset calibration
    func resetCalibration() {
        instrumentProfile = nil
    }
    
    // MARK: - Private methods
    
    // Calculate similarity between two spectral profiles
    private func calculateSpectralSimilarity(_ profile1: [Float], _ profile2: [Float]) -> Float {
        // Ensure same length
        let minLength = min(profile1.count, profile2.count)
        
        // Normalize both profiles
        var norm1 = [Float](repeating: 0, count: minLength)
        var norm2 = [Float](repeating: 0, count: minLength)
        
        // Extract and normalize the profiles to the same length
        for i in 0..<minLength {
            norm1[i] = profile1[i]
            norm2[i] = profile2[i]
        }
        
        // Calculate cosine similarity
        var dotProduct: Float = 0
        var magnitude1: Float = 0
        var magnitude2: Float = 0
        
        for i in 0..<minLength {
            dotProduct += norm1[i] * norm2[i]
            magnitude1 += norm1[i] * norm1[i]
            magnitude2 += norm2[i] * norm2[i]
        }
        
        magnitude1 = sqrt(magnitude1)
        magnitude2 = sqrt(magnitude2)
        
        // Avoid division by zero
        if magnitude1 > 0 && magnitude2 > 0 {
            return dotProduct / (magnitude1 * magnitude2)
        }
        
        return 0
    }
    
    // Detect transients (sudden increases in energy)
    private func detectTransient(in buffer: AVAudioPCMBuffer, previousBuffer: AVAudioPCMBuffer?) -> Bool {
        guard let channelData = buffer.floatChannelData, 
              let prevChannelData = previousBuffer?.floatChannelData else {
            return false
        }
        
        // Calculate RMS energy of current buffer
        var currentEnergy: Float = 0
        let frameCount = Int(buffer.frameLength)
        
        vDSP_measqv(channelData[0], 1, &currentEnergy, vDSP_Length(frameCount))
        currentEnergy = sqrt(currentEnergy / Float(frameCount))
        
        // Calculate RMS energy of previous buffer
        var previousEnergy: Float = 0
        let prevFrameCount = Int(previousBuffer!.frameLength)
        
        vDSP_measqv(prevChannelData[0], 1, &previousEnergy, vDSP_Length(prevFrameCount))
        previousEnergy = sqrt(previousEnergy / Float(prevFrameCount))
        
        // Check for significant increase in energy
        let energyRatio = currentEnergy / max(previousEnergy, 0.001) // Avoid division by zero
        
        return energyRatio > 1.5 // 50% increase threshold
    }
}