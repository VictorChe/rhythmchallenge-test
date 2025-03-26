import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: ResultsViewModel
    @State private var selectedResult: TrainingResult?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Training Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                if viewModel.trainingResults.isEmpty {
                    emptyResultsView
                } else {
                    resultsListView
                }
                
                Spacer()
            }
            .padding()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.loadResults()
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
                .padding()
            
            Text("No training results yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Complete a rhythm training session to see your results here")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.15))
        .cornerRadius(20)
        .padding(.vertical, 40)
    }
    
    private var resultsListView: some View {
        VStack(spacing: 16) {
            // Filter controls
            HStack {
                Text("Filter:")
                    .foregroundColor(AppColor.secondaryText)
                
                Button(action: {
                    viewModel.filterByPatternType(nil) // Show all
                }) {
                    Text("All")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.currentFilter == nil ? AppColor.accent : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.currentFilter == nil ? .white : AppColor.text)
                        .cornerRadius(8)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(RhythmPatternType.allCases) { patternType in
                            Button(action: {
                                viewModel.filterByPatternType(patternType)
                            }) {
                                Text(patternType.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.currentFilter == patternType ? AppColor.accent : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.currentFilter == patternType ? .white : AppColor.text)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            
            // Results list
            VStack(spacing: 12) {
                ForEach(viewModel.filteredResults) { result in
                    ResultCard(
                        result: result,
                        isSelected: selectedResult?.id == result.id,
                        onTap: {
                            withAnimation {
                                if selectedResult?.id == result.id {
                                    selectedResult = nil
                                } else {
                                    selectedResult = result
                                }
                            }
                        }
                    )
                }
            }
            
            // Stats summary
            if !viewModel.filteredResults.isEmpty {
                resultsSummary
            }
        }
    }
    
    private var resultsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(AppColor.text)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    statRow(
                        label: "Average Accuracy",
                        value: "\(String(format: "%.1f%%", viewModel.averageAccuracy))"
                    )
                    
                    statRow(
                        label: "Best Score",
                        value: "\(viewModel.bestGrade)"
                    )
                    
                    statRow(
                        label: "Total Sessions",
                        value: "\(viewModel.filteredResults.count)"
                    )
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.averageAccuracy / 100))
                        .stroke(
                            viewModel.averageAccuracy > 90 ? AppColor.accuracyPerfect :
                                viewModel.averageAccuracy > 75 ? AppColor.accuracyGood :
                                viewModel.averageAccuracy > 60 ? AppColor.accuracyInaccurate :
                                AppColor.accuracyMiss,
                            lineWidth: 10
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(viewModel.averageAccuracy))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.text)
                        
                        Text("Overall")
                            .font(.caption)
                            .foregroundColor(AppColor.secondaryText)
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(16)
        .padding(.top, 16)
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColor.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppColor.text)
        }
        .padding(.vertical, 4)
    }
}