import SwiftUI
import AVFoundation

// MARK: - View Extensions
extension View {
    // Apply default corner radius
    func roundedCorner() -> some View {
        self.cornerRadius(AppDimension.cornerRadius)
    }
    
    // Apply primary button style
    func primaryButtonStyle() -> some View {
        self
            .frame(height: AppDimension.buttonHeight)
            .background(AppColor.accent)
            .foregroundColor(.white)
            .cornerRadius(AppDimension.cornerRadius)
            .shadow(radius: 2)
    }
    
    // Apply secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .frame(height: AppDimension.buttonHeight)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(AppColor.text)
            .cornerRadius(AppDimension.cornerRadius)
    }
    
    // Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Double Extensions
extension Double {
    // Format BPM with no decimal places
    var formattedBPM: String {
        return String(format: "%.0f", self)
    }
    
    // Format percentage
    var formattedPercentage: String {
        return String(format: "%.1f%%", self * 100)
    }
    
    // Format seconds
    var formattedSeconds: String {
        return String(format: "%.2fs", self)
    }
    
    // Format milliseconds
    var formattedMilliseconds: String {
        return String(format: "%.1fms", self)
    }
}

// MARK: - Color Extensions
extension Color {
    // Initialize with hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions
extension Date {
    // Format date to string
    func formatted(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - AVAudioPCMBuffer Extensions
extension AVAudioPCMBuffer {
    // Get peak amplitude of buffer
    var peakAmplitude: Float {
        guard let channelData = self.floatChannelData else { return 0 }
        
        let frameCount = Int(self.frameLength)
        let channelCount = Int(self.format.channelCount)
        var maxAmplitude: Float = 0
        
        for channel in 0..<channelCount {
            for frame in 0..<frameCount {
                let amplitude = abs(channelData[channel][frame])
                maxAmplitude = max(maxAmplitude, amplitude)
            }
        }
        
        return maxAmplitude
    }
}