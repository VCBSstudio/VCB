import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    private let screenRecorder = ScreenRecorder()
    
    var body: some View {
        VStack {
            Text(isRecording ? "Recording..." : "Ready to Record")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func startRecording() {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("screenRecording.mov")
        screenRecorder.startRecording(to: fileURL)
    }
    
    private func stopRecording() {
        screenRecorder.stopRecording()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
