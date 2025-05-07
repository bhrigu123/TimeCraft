import SwiftUI

struct ContentView: View {
    @StateObject var timerManager = TimerManager()

    var body: some View {
        VStack(spacing: 15) {
            Text(timerManager.formattedTime())
                .font(.largeTitle)
                .padding()

            HStack {
                if timerManager.timerMode == .stopped {
                    Button("Start Timer") {
                        timerManager.startTimer()
                    }
                    .padding(.horizontal)
                } else {
                    Button("Stop Timer") {
                        timerManager.stopTimer()
                    }
                    .padding(.horizontal)
                }

                Button("Reset Timer") {
                    timerManager.resetTimer()
                }
                .padding(.horizontal)
                .disabled(timerManager.secondsElapsed == 0 && timerManager.timerMode == .stopped)
            }
            .padding(.bottom)
            
            Button("Quit App") {
                 NSApplication.shared.terminate(nil)
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(minWidth: 250, minHeight: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 