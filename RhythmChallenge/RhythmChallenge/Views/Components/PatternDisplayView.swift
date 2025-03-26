import SwiftUI

struct PatternDisplayView: View {
    let pattern: RhythmPattern
    let isActive: Bool
    let highlightedBeat: Int?
    
    init(pattern: RhythmPattern, isActive: Bool = true, highlightedBeat: Int? = nil) {
        self.pattern = pattern
        self.isActive = isActive
        self.highlightedBeat = highlightedBeat
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Pattern name
            Text(pattern.name)
                .font(.headline)
                .foregroundColor(isActive ? AppColor.text : AppColor.secondaryText)
            
            // Beat circles
            HStack(spacing: 4) {
                ForEach(pattern.beats) { beat in
                    BeatView(
                        beat: beat,
                        isHighlighted: highlightedBeat == beat.id,
                        isEnabled: isActive
                    )
                }
            }
            .padding(.vertical, 4)
            
            // Difficulty indicator
            difficultyView
        }
        .padding()
        .background(isActive ? Color.black.opacity(0.1) : Color.clear)
        .cornerRadius(12)
    }
    
    private var difficultyView: some View {
        HStack {
            Text("Difficulty:")
                .font(.caption)
                .foregroundColor(AppColor.secondaryText)
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Circle()
                        .fill(index <= pattern.type.difficulty ? AppColor.accent : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

struct BeatView: View {
    let beat: Beat
    let isHighlighted: Bool
    let isEnabled: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: beat.accent ? 20 : 16, height: beat.accent ? 20 : 16)
            
            if beat.isRest {
                Text("R")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(textColor)
            }
        }
        .overlay(
            Circle()
                .stroke(strokeColor, lineWidth: beat.accent ? 2 : 1)
        )
        .scaleEffect(isHighlighted ? 1.3 : 1.0)
        .animation(.spring(response: 0.2), value: isHighlighted)
    }
    
    private var fillColor: Color {
        if !isEnabled {
            return Color.clear
        }
        
        if isHighlighted {
            return AppColor.accent
        }
        
        if beat.accent {
            return AppColor.accent.opacity(0.2)
        }
        
        return Color.clear
    }
    
    private var strokeColor: Color {
        if !isEnabled {
            return Color.gray.opacity(0.3)
        }
        
        if isHighlighted {
            return AppColor.accent
        }
        
        return beat.accent ? AppColor.accent.opacity(0.8) : AppColor.secondaryText
    }
    
    private var textColor: Color {
        if !isEnabled {
            return Color.gray.opacity(0.5)
        }
        
        return isHighlighted ? .white : AppColor.secondaryText
    }
}