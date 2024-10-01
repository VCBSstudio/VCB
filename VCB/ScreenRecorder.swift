import AVFoundation
import Cocoa

class ScreenRecorder: NSObject {
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    
    func startRecording(to url: URL) {
        let screen = NSScreen.main!
        let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
        
        // 1. 创建捕获会话
        captureSession = AVCaptureSession()
        
        // 2. 获取屏幕输入
        guard let screenInput = AVCaptureScreenInput(displayID: displayId) else { return }
        
        // 3. 添加屏幕输入到会话
        if captureSession!.canAddInput(screenInput) {
            captureSession!.addInput(screenInput)
        }
        
        // 4. 获取麦克风输入
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession!.canAddInput(audioInput) {
                    captureSession!.addInput(audioInput)
                }
            } catch {
                print("Error adding audio input: \(error)")
            }
        }
        
        // 5. 创建输出对象
        movieOutput = AVCaptureMovieFileOutput()
        
        // 6. 添加输出到会话
        if captureSession!.canAddOutput(movieOutput!) {
            captureSession!.addOutput(movieOutput!)
        }
        
        // 7. 启动会话
        captureSession!.startRunning()
        
        // 8. 开始录制到指定的文件
        movieOutput!.startRecording(to: url, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput?.stopRecording()
        captureSession?.stopRunning()
    }
}

extension ScreenRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        print("Finished recording to: \(outputFileURL)")
    }
}
