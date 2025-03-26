import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var resultsViewModel: ResultsViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                if resultsViewModel.results.isEmpty {
                    // Empty state
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        Text("Нет данных о тренировках")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Начните тренировку, чтобы увидеть результаты")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    // Results content
                    ScrollView {
                        VStack(spacing: 25) {
                            // Summary card
                            SummaryCard(
                                resultsCount: resultsViewModel.results.count,
                                averageAccuracy: resultsViewModel.averageAccuracy,
                                totalTrainingTime: resultsViewModel.formattedTotalTime
                            )
                            .padding(.top)
                            
                            // Best session card
                            if let bestResult = resultsViewModel.bestResult {
                                BestSessionCard(result: bestResult)
                            }
                            
                            // Recent results
                            Text("Последние тренировки")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Results list
                            ForEach(resultsViewModel.results.indices.reversed().prefix(10), id: \.self) { index in
                                ResultRow(result: resultsViewModel.results[index], index: index + 1)
                            }
                            
                            // Clear button
                            Button(action: {
                                resultsViewModel.clearResults()
                            }) {
                                Text("Очистить результаты")
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 1) // Trigger scroll view
                }
            }
            .navigationTitle("Результаты")
        }
    }
}

struct SummaryCard: View {
    let resultsCount: Int
    let averageAccuracy: Double
    let totalTrainingTime: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Общая статистика")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                StatItem(value: "\(resultsCount)", label: "Тренировок")
                
                StatItem(value: "\(Int(averageAccuracy))%", label: "Средняя точность")
                
                StatItem(value: totalTrainingTime, label: "Общее время")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct BestSessionCard: View {
    let result: TrainingResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Лучшая тренировка")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(result.accuracyPercentage))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
            
            HStack(spacing: 20) {
                HitStat(count: result.perfectHits, label: "Идеально", color: .green)
                HitStat(count: result.goodHits, label: "Хорошо", color: .blue)
                HitStat(count: result.inaccurateHits, label: "Неточно", color: .yellow)
                HitStat(count: result.missedHits, label: "Мимо", color: .red)
            }
            
            Text("Длительность: \(result.formattedDuration)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct HitStat: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

struct ResultRow: View {
    let result: TrainingResult
    let index: Int
    
    var body: some View {
        HStack {
            Text("#\(index)")
                .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Точность: \(Int(result.accuracyPercentage))%")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Длительность: \(result.formattedDuration)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Accuracy color indicator
            Circle()
                .fill(accuracyColor(result.accuracyPercentage))
                .frame(width: 15, height: 15)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 90 {
            return .green
        } else if accuracy >= 75 {
            return .blue
        } else if accuracy >= 50 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
            .environmentObject(ResultsViewModel())
            .preferredColorScheme(.dark)
    }
}
