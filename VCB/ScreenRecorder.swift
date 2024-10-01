//
//  ScreenRecorder.swift
//  VCB
//
//  Created by helinyu on 2024/10/2.
//

import Foundation
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
        
        // 4. 创建输出对象
        movieOutput = AVCaptureMovieFileOutput()
        
        // 5. 添加输出到会话
        if captureSession!.canAddOutput(movieOutput!) {
            captureSession!.addOutput(movieOutput!)
        }
        
        // 6. 启动会话
        captureSession!.startRunning()
        
        // 7. 开始录制到指定的文件
        movieOutput!.startRecording(to: url, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput?.stopRecording()
        captureSession?.stopRunning()
    }
}

extension ScreenRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        print("Finished recording to ll: \(outputFileURL)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, fromConnections connections: [AVAssetExportSession]) {
        print("Finished recording to: \(outputFileURL)")
    }
}
