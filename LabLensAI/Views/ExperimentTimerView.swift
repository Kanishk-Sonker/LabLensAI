import SwiftUI

public struct ExperimentTimerView: View {
    @State private var remainingSeconds: Int = 600
    @State private var totalSeconds: Int = 600
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    
    public init() {}
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("Centrifugation Protocol Timer")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        remainingSeconds < 60 ? Color.red : Color.blue,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                    .animation(.easeInOut, value: progress)
                
                VStack(spacing: 4) {
                    Text(timeString(from: remainingSeconds))
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                Button(action: toggleTimer) {
                    Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 130, height: 48)
                        .background(isRunning ? Color.orange : Color.blue)
                        .cornerRadius(24)
                }
                
                Button(action: resetTimer) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 110, height: 48)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(24)
                }
            }
        }
        .padding()
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isRunning = false
                }
            }
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = totalSeconds
    }
    
    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
