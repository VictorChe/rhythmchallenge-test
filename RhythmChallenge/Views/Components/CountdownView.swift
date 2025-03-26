import SwiftUI

struct CountdownView: View {
    let count: Int
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Count number
            Text("\(count)")
                .font(.system(size: 180, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
                .onChange(of: count) { _ in
                    // Reset animation when count changes
                    scale = 0.5
                    opacity = 0
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
        }
    }
}
