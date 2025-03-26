import SwiftUI

struct PatternDisplayView: View {
    let currentPattern: RhythmPattern?
    let nextPattern: RhythmPattern?
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            // Current pattern
            PatternCard(
                pattern: currentPattern,
                isHighlighted: isHighlighted,
                isCurrent: true
            )
            
            // Next pattern (preview)
            PatternCard(
                pattern: nextPattern,
                isHighlighted: false,
                isCurrent: false
            )
            .opacity(0.6)
        }
    }
}

struct PatternCard: View {
    let pattern: RhythmPattern?
    let isHighlighted: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Pattern name
            Text(pattern?.type.rawValue ?? "")
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            // Pattern visualization
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                if let patternType = pattern?.type {
                    Group {
                        switch patternType {
                        case .quarterNotes:
                            QuarterNoteView()
                        case .eighthPairs:
                            EighthPairsView()
                        case .triplets:
                            TripletView()
                        case .quarterRest:
                            QuarterRestView()
                        }
                    }
                    .scaleEffect(0.7)
                } else {
                    Text("Нет паттерна")
                        .foregroundColor(.gray)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isHighlighted ? Color.blue : Color.clear, lineWidth: 3)
            )
            
            // Label
            if isCurrent {
                Text("Текущий")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else {
                Text("Следующий")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct QuarterNoteView: View {
    var body: some View {
        Text("♩")
            .font(.system(size: 80))
            .foregroundColor(.white)
    }
}

struct EighthPairsView: View {
    var body: some View {
        HStack(spacing: 2) {
            Text("♪")
                .font(.system(size: 60))
            Text("♪")
                .font(.system(size: 60))
        }
        .foregroundColor(.white)
    }
}

struct TripletView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("3")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .offset(y: 10)
            
            HStack(spacing: 5) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 15, height: 15)
                }
            }
        }
    }
}

struct QuarterRestView: View {
    var body: some View {
        Text("𝄽")
            .font(.system(size: 70))
            .foregroundColor(.white)
    }
}
