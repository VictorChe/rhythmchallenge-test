import SwiftUI

struct BPMControlView: View {
    @Binding var bpm: Double
    let minBPM: Double
    let maxBPM: Double
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // BPM display
            Text("\(Int(bpm))")
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.white)
            
            Text("BPM")
                .font(.headline)
                .foregroundColor(.gray)
            
            // Plus/Minus buttons
            HStack(spacing: 50) {
                Button(action: {
                    onDecrement()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    onIncrement()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
            }
            
            // Slider
            Slider(
                value: $bpm,
                in: minBPM...maxBPM,
                step: 1,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            .accentColor(.blue)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // BPM range display
            HStack {
                Text("\(Int(minBPM))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("\(Int(maxBPM))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 25)
        }
    }
}
