import SwiftUI

struct MetronomeView: View {
    @ObservedObject var viewModel: MetronomeViewModel
    
    var body: some View {
        ZStack {
            // Основной интерфейс
            ScrollView {
                VStack(spacing: 30) {
                    // Заголовок
                    Text("Метроном")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Визуализация паттерна
                    PatternDisplayView(
                        pattern: viewModel.selectedPattern,
                        currentBeat: viewModel.currentBeat,
                        isRunning: viewModel.isRunning
                    )
                    
                    // Элемент управления BPM
                    BPMControlView(viewModel: viewModel)
                    
                    // Выбор паттерна
                    patternSelectionView
                    
                    // Кнопка старт/стоп
                    startStopButton
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .background(AppColor.background)
            .edgesIgnoringSafeArea(.bottom)
            
            // Наложение обратного отсчета
            if viewModel.isCountingDown {
                CountdownView(count: viewModel.countdownCount)
            }
        }
    }
    
    // Выбор ритмического паттерна
    private var patternSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Выберите ритмический паттерн:")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.patternOptions, id: \.id) { pattern in
                        Button(action: {
                            viewModel.selectPattern(pattern)
                        }) {
                            Text(pattern.name)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedPattern.id == pattern.id ?
                                    AppColor.accent : Color.gray.opacity(0.3)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
    }
    
    // Кнопка старт/стоп
    private var startStopButton: some View {
        Button(action: {
            if viewModel.isRunning {
                viewModel.stopMetronome()
            } else {
                viewModel.startMetronome()
            }
        }) {
            HStack {
                Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 24))
                Text(viewModel.isRunning ? "Остановить" : "Запустить")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(minWidth: 200)
            .padding()
            .background(viewModel.isRunning ? Color.red.opacity(0.8) : AppColor.accent)
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.top, 10)
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView(viewModel: MetronomeViewModel())
            .preferredColorScheme(.dark)
    }
}