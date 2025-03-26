import SwiftUI

struct PatternSelector: View {
    @Binding var selectedPattern: RhythmPattern
    let patterns: [RhythmPattern]
    let onPatternSelected: (RhythmPattern) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Rhythm Pattern")
                .font(.headline)
                .foregroundColor(AppColor.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(patterns) { pattern in
                        PatternCard(
                            pattern: pattern,
                            isSelected: pattern.id == selectedPattern.id,
                            onTap: {
                                selectedPattern = pattern
                                onPatternSelected(pattern)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct PatternCard: View {
    let pattern: RhythmPattern
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pattern.name)
                .font(.headline)
                .foregroundColor(isSelected ? .white : AppColor.text)
            
            Text("Difficulty: \(String(repeating: "•", count: pattern.type.difficulty))")
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : AppColor.secondaryText)
            
            PatternVisualizer(pattern: pattern)
                .frame(height: 30)
        }
        .padding()
        .frame(width: 180)
        .background(isSelected ? AppColor.accent : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: isSelected ? AppColor.accent.opacity(0.4) : Color.clear, radius: 5)
        .onTapGesture {
            onTap()
        }
    }
}

struct PatternVisualizer: View {
    let pattern: RhythmPattern
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(pattern.beats) { beat in
                BeatCircle(isAccent: beat.accent, isRest: beat.isRest)
            }
        }
    }
}

struct BeatCircle: View {
    let isAccent: Bool
    let isRest: Bool
    
    var body: some View {
        Circle()
            .stroke(isRest ? Color.clear : (isAccent ? AppColor.accent : AppColor.secondaryText), lineWidth: isAccent ? 2 : 1)
            .background(Circle().fill(isRest ? Color.clear : (isAccent ? AppColor.accent.opacity(0.3) : Color.clear)))
            .frame(width: 12, height: 12)
    }
}