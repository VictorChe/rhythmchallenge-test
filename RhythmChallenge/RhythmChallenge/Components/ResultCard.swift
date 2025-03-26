import SwiftUI

struct ResultCard: View {
    let result: TrainingResult
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(result.patternType.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : AppColor.text)
                
                Spacer()
                
                Text(result.grade)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : gradeColor)
            }
            
            Divider()
                .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.3))
            
            // Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BPM: \(Int(result.bpm))")
                        .font(.subheadline)
                    Text("Accuracy: \(String(format: "%.1f%%", result.averageAccuracy))")
                        .font(.subheadline)
                }
                .foregroundColor(isSelected ? .white.opacity(0.9) : AppColor.secondaryText)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Duration: \(formatSeconds(result.duration))")
                        .font(.subheadline)
                    Text("Date: \(formatDate(result.date))")
                        .font(.subheadline)
                }
                .foregroundColor(isSelected ? .white.opacity(0.9) : AppColor.secondaryText)
            }
            
            // Statistics
            if isSelected {
                VStack(spacing: 8) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 16) {
                        statItem(value: result.perfectCount, label: "Perfect", color: AppColor.accuracyPerfect)
                        statItem(value: result.goodCount, label: "Good", color: AppColor.accuracyGood)
                        statItem(value: result.inaccurateCount, label: "Off", color: AppColor.accuracyInaccurate)
                        statItem(value: result.missCount, label: "Miss", color: AppColor.accuracyMiss)
                    }
                    
                    Text("Average Deviation: \(String(format: "%.1fms", result.averageDeviation))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .padding()
        .background(isSelected ? AppColor.accent : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: isSelected ? AppColor.accent.opacity(0.4) : Color.clear, radius: 5)
        .onTapGesture {
            onTap()
        }
    }
    
    private var gradeColor: Color {
        switch result.grade.prefix(1) {
        case "A": return AppColor.accuracyPerfect
        case "B": return AppColor.accuracyGood
        case "C": return AppColor.accuracyInaccurate
        default: return AppColor.accuracyMiss
        }
    }
    
    private func statItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(minWidth: 50)
    }
    
    private func formatSeconds(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}