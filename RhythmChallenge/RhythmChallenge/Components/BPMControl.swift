import SwiftUI

struct BPMControl: View {
    @Binding var bpm: Double
    private let minBPM = AudioConstants.minBPM
    private let maxBPM = AudioConstants.maxBPM
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // BPM display
            Text("BPM: \(Int(bpm))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColor.text)
            
            // Slider
            HStack {
                Text("\(Int(minBPM))")
                    .font(.footnote)
                    .foregroundColor(AppColor.secondaryText)
                
                ZStack(alignment: .leading) {
                    // Slider track
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // Slider filled section
                    Rectangle()
                        .fill(AppColor.accent)
                        .frame(width: sliderWidth, height: 6)
                        .cornerRadius(3)
                    
                    // Slider thumb
                    Circle()
                        .fill(AppColor.accent)
                        .frame(width: 24, height: 24)
                        .shadow(radius: 2)
                        .offset(x: sliderWidth - 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    updateBPM(at: value.location.x)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                }
                .frame(height: 24)
                
                Text("\(Int(maxBPM))")
                    .font(.footnote)
                    .foregroundColor(AppColor.secondaryText)
            }
            
            // Quick preset buttons
            HStack(spacing: 12) {
                presetButton(value: 60, "Slow")
                presetButton(value: 90, "Medium")
                presetButton(value: 120, "Fast")
                presetButton(value: 140, "Faster")
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var sliderWidth: CGFloat {
        let percentage = (bpm - minBPM) / (maxBPM - minBPM)
        return max(0, min(1, percentage)) * .infinity // Properly handled in GeometryReader
    }
    
    private func updateBPM(at position: CGFloat) {
        let totalWidth = UIScreen.main.bounds.width - 80 // Approximate padding
        let percentage = max(0, min(1, position / totalWidth))
        bpm = minBPM + (maxBPM - minBPM) * Double(percentage)
    }
    
    private func presetButton(value: Double, _ label: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                bpm = value
            }
        }) {
            VStack {
                Text("\(Int(value))")
                    .font(.headline)
                
                Text(label)
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(bpm == value ? AppColor.accent : Color.gray.opacity(0.2))
            .foregroundColor(bpm == value ? .white : AppColor.text)
            .cornerRadius(8)
        }
    }
}

// SwiftUI Preview
struct BPMControl_Previews: PreviewProvider {
    static var previews: some View {
        let previewBPM = State(initialValue: 90.0)
        return BPMControl(bpm: previewBPM.projectedValue)
            .preferredColorScheme(.dark)
            .padding()
    }
}