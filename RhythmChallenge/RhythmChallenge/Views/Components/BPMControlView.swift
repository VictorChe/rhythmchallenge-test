import SwiftUI

struct BPMControlView: View {
    @Binding var bpm: Double
    @State private var isEditing = false
    
    private let minBPM: Double = 40
    private let maxBPM: Double = 220
    
    var body: some View {
        VStack(spacing: 16) {
            // BPM Display
            Text("\(Int(bpm)) BPM")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.text)
                .frame(height: 44)
            
            // Slider
            HStack(spacing: 12) {
                Text("\(Int(minBPM))")
                    .font(.caption)
                    .foregroundColor(AppColor.secondaryText)
                
                Slider(
                    value: $bpm,
                    in: minBPM...maxBPM,
                    step: 1
                ) {
                    Text("BPM")
                } minimumValueLabel: {
                    Text("Slow")
                        .font(.caption2)
                        .foregroundColor(AppColor.secondaryText)
                } maximumValueLabel: {
                    Text("Fast")
                        .font(.caption2)
                        .foregroundColor(AppColor.secondaryText)
                } onEditingChanged: { editing in
                    isEditing = editing
                }
                .accentColor(AppColor.accent)
                
                Text("\(Int(maxBPM))")
                    .font(.caption)
                    .foregroundColor(AppColor.secondaryText)
            }
            
            // Preset buttons
            HStack(spacing: 12) {
                presetButton(label: "Slow", bpmValue: 60)
                presetButton(label: "Medium", bpmValue: 100)
                presetButton(label: "Fast", bpmValue: 140)
                presetButton(label: "Extreme", bpmValue: 180)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func presetButton(label: String, bpmValue: Double) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                bpm = bpmValue
            }
        }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(bpm == bpmValue ? AppColor.accent : Color.gray.opacity(0.2))
                .foregroundColor(bpm == bpmValue ? .white : AppColor.text)
                .cornerRadius(8)
        }
    }
}