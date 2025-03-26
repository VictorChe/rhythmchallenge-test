import SwiftUI

struct BPMControl: View {
    @Binding var bpm: Double
    let minBPM: Double
    let maxBPM: Double
    
    init(bpm: Binding<Double>, minBPM: Double = AudioConstants.minBPM, maxBPM: Double = AudioConstants.maxBPM) {
        self._bpm = bpm
        self.minBPM = minBPM
        self.maxBPM = maxBPM
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // BPM Display
            Text("\(Int(bpm)) BPM")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColor.text)
                .frame(height: 50)
            
            // Slider
            Slider(value: $bpm, in: minBPM...maxBPM, step: 1.0)
                .accentColor(AppColor.accent)
                .padding(.horizontal)
            
            // Control buttons
            HStack(spacing: 16) {
                // Large decrease
                Button(action: {
                    adjustBPM(by: -5)
                }) {
                    Image(systemName: "minus.square.fill")
                        .font(.system(size: 28))
                }
                .foregroundColor(AppColor.accent)
                
                // Small decrease
                Button(action: {
                    adjustBPM(by: -1)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                }
                .foregroundColor(AppColor.accent)
                
                // Small increase
                Button(action: {
                    adjustBPM(by: 1)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                }
                .foregroundColor(AppColor.accent)
                
                // Large increase
                Button(action: {
                    adjustBPM(by: 5)
                }) {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 28))
                }
                .foregroundColor(AppColor.accent)
            }
            
            // Tap tempo button
            Button(action: {
                // Tap tempo functionality would be implemented here in the full app
            }) {
                Text("Tap Tempo")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(AppColor.secondaryAccent)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func adjustBPM(by amount: Double) {
        let newValue = bpm + amount
        bpm = max(minBPM, min(maxBPM, newValue))
    }
}