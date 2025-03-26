import SwiftUI

struct CountdownView: View {
    let count: Int
    let isActive: Bool
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .opacity(isActive ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isActive)
            
            // Countdown circle
            VStack {
                Text("Get Ready")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(AppColor.accent, lineWidth: 4)
                        .frame(width: 120, height: 120)
                    
                    Text("\(count)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onChange(of: count) { _ in
                            animateCountChange()
                        }
                }
                
                Text("Starting soon...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 20)
            }
            .padding(40)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.5), radius: 10)
            .opacity(isActive ? 1.0 : 0.0)
            .scaleEffect(isActive ? 1.0 : 0.8)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
        }
        .onChange(of: count) { newCount in
            if newCount == 0 && isActive {
                onComplete()
            }
        }
    }
    
    private func animateCountChange() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = 1.4
            opacity = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}