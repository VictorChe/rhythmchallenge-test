import Foundation

class TimingService {
    // MARK: - Properties
    private var startTime: UInt64 = 0
    private let machTimebase: mach_timebase_info_data_t
    
    // MARK: - Initialization
    init() {
        // Initialize mach timebase info
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        machTimebase = timebase
    }
    
    // MARK: - Public methods
    func startTiming() {
        startTime = mach_absolute_time()
    }
    
    func getElapsedTimeNanoseconds() -> UInt64 {
        let currentTime = mach_absolute_time()
        let elapsedMachTime = currentTime - startTime
        
        // Convert to nanoseconds using timebase
        return elapsedMachTime * UInt64(machTimebase.numer) / UInt64(machTimebase.denom)
    }
    
    func getElapsedTimeMilliseconds() -> Double {
        return Double(getElapsedTimeNanoseconds()) / 1_000_000.0
    }
    
    func getElapsedTimeSeconds() -> Double {
        return Double(getElapsedTimeNanoseconds()) / 1_000_000_000.0
    }
    
    // Calculate the precise interval for a given BPM
    func intervalForBPM(_ bpm: Double) -> UInt64 {
        // Calculate beat interval in seconds
        let intervalInSeconds = 60.0 / bpm
        
        // Convert to nanoseconds
        let intervalInNanoseconds = UInt64(intervalInSeconds * 1_000_000_000)
        
        return intervalInNanoseconds
    }
    
    // Calculate deviation between target and actual time as percentage of interval
    func calculateDeviation(targetTime: TimeInterval, actualTime: TimeInterval, beatDuration: TimeInterval) -> Double {
        let deviation = actualTime - targetTime
        return deviation / beatDuration
    }
    
    // High-precision wait function (busy-wait for maximum precision)
    func preciseWait(nanoseconds: UInt64) {
        let startTime = mach_absolute_time()
        let targetTime = startTime + (nanoseconds * UInt64(machTimebase.denom) / UInt64(machTimebase.numer))
        
        // Busy-wait for maximum precision
        while mach_absolute_time() < targetTime { 
            // Just keep checking
        }
    }
}
