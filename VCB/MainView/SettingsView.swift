//
//  SettingsView.swift
//  VCB
//
//  Created by helinyu on 2024/10/23.
//

import SwiftUI
import Sparkle
import ServiceManagement
import KeyboardShortcuts
import MatrixColorSelector

struct SettingsView: View {
    var appDelegate = AppDelegate.shared
    @State private var userColor: Color = Color.black
    @State private var launchAtLogin = false
    
    @AppStorage(kEncoder)          private var encoder: Encoder = .h264
    @AppStorage(kVideoFormat)      private var videoFormat: VideoFormat = .mp4
    @AppStorage(kAudioFormat)      private var audioFormat: AudioFormat = .aac
    @AppStorage(kAudioQuality)     private var audioQuality: AudioQuality = .high
    @AppStorage(kPixelFormat)      private var pixelFormat: PixFormat = .delault
    @AppStorage(kBackground)       private var background: BackgroundType = .wallpaper
    @AppStorage(kHideSelf)         private var hideSelf: Bool = true
    @AppStorage(kCountdown)        private var countdown: Int = 0
    @AppStorage(kPoSafeDelay)      private var poSafeDelay: Int = 1
    @AppStorage(kSaveDirectory)    private var saveDirectory: String?
    @AppStorage(kHighlightMouse)   private var highlightMouse: Bool = false
    @AppStorage(kIncludeMenuBar)   private var includeMenuBar: Bool = true
    @AppStorage(kHideDesktopFiles) private var hideDesktopFiles: Bool = false
    @AppStorage(kTtrimAfterRecord)  private var trimAfterRecord: Bool = false
    @AppStorage(kWithAlpha)        private var withAlpha: Bool = false
    @AppStorage(kShowOnDock)       private var showOnDock: Bool = true
    @AppStorage(kShowMenuBar)       private var showMenubar: Bool = false
    @AppStorage(kRemuxAudio)       private var remuxAudio: Bool = true
    @AppStorage(kEnableAEC)        private var enableAEC: Bool = false
    @AppStorage(kMiniStatusBar)    private var miniStatusBar: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 17){
                VStack(alignment: .leading) {
                    GroupBox(label: Text("Video Settings".local).fontWeight(.bold)) {
                        Form() {
                            Picker("Format", selection: $videoFormat) {
                                Text("MOV").tag(VideoFormat.mov)
                                Text("MP4").tag(VideoFormat.mp4)
                            }
                            .padding([.leading, .trailing], 10).padding(.bottom, 6)
                            .disabled(withAlpha)
                            Picker("Encoder", selection: $encoder) {
                                Text("H.264 + sRGB").tag(Encoder.h264)
                                Text("H.265 + P3").tag(Encoder.h265)
                            }
                            .padding([.leading, .trailing], 10)
                            .disabled(withAlpha)
                        }.frame(maxWidth: .infinity).padding(.top, 10)
                        
                        Toggle(isOn: $withAlpha) { Text("Recording with Alpha Channel") }
                            .onChange(of: withAlpha) {alpha in
                                if alpha {
                                    encoder = Encoder.h265; videoFormat = VideoFormat.mov
                                } else {
                                    if background == .clear { background = .wallpaper }
                                }}
                            .padding([.leading, .trailing, .bottom], 10).padding(.top, 3.5)
                            .toggleStyle(.checkbox)
                    }
                    GroupBox(label: Text("Audio Settings".local).fontWeight(.bold)) {
                        Form() {
                            Picker("Quality", selection: $audioQuality) {
                                if audioFormat == .alac || audioFormat == .flac {
                                    Text("Lossless").tag(audioQuality)
                                }
                                Text("Normal - 128Kbps").tag(AudioQuality.normal)
                                Text("Good - 192Kbps").tag(AudioQuality.good)
                                Text("High - 256Kbps").tag(AudioQuality.high)
                                Text("Extreme - 320Kbps").tag(AudioQuality.extreme)
                            }
                            .padding([.leading, .trailing], 10).padding(.bottom, 6)
                            .disabled(audioFormat == .alac || audioFormat == .flac)
                            Picker("Format", selection: $audioFormat) {
                                Text("MP3").tag(AudioFormat.mp3)
                                Text("AAC").tag(AudioFormat.aac)
                                Text("ALAC (Lossless)").tag(AudioFormat.alac)
                                Text("FLAC (Lossless)").tag(AudioFormat.flac)
                                Text("Opus").tag(AudioFormat.opus)
                            }.padding([.leading, .trailing], 10)
                        }.frame(maxWidth: .infinity).padding(.top, 10)
                        Toggle(isOn: $remuxAudio) { Text("Record Microphone to Main Track") }
                            .padding([.leading, .trailing], 10).padding(.top, 5)
                            .toggleStyle(.checkbox)
                            .disabled(isMacOS12)
                        Toggle(isOn: $enableAEC) { Text("Enable Acoustic Echo Cancellation") }
                            .padding([.leading, .trailing,.bottom], 10).padding(.top, 4)
                            .toggleStyle(.checkbox)
                    }
                }.frame(width: 270)
                VStack {
                    GroupBox(label: Text("Other Settings".local).fontWeight(.bold)) {
                        Form() {
                            Picker("Delay Before Recording", selection: $countdown) {
                                Text("0"+"s".local).tag(0)
                                Text("3"+"s".local).tag(3)
                                Text("5"+"s".local).tag(5)
                                Text("10"+"s".local).tag(10)
                            }.padding([.leading, .trailing], 10).padding(.bottom, 6)
                            Picker("Presenter Overlay Delay", selection: $poSafeDelay) {
                                Text("1"+"s".local).tag(1)
                                Text("2"+"s".local).tag(2)
                                Text("3"+"s".local).tag(3)
                                Text("5"+"s".local).tag(5)
                            }
                            .padding([.leading, .trailing], 10)
                            .disabled(!isMacOS14)
                        }.frame(maxWidth: .infinity).padding(.top, 10)
                        MatrixColorSelector("Set custom background color:", selection: $userColor)
                            .padding([.leading, .trailing], 10)
                            .onChange(of: userColor) { userColor in ud.setColor(userColor, forKey: "userColor") }
                        Toggle(isOn: $trimAfterRecord) { Text("Open video trimmer after recording") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                        Toggle(isOn: $hideSelf) { Text("Exclude QuickRecorder itself") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                        Toggle(isOn: $includeMenuBar) { Text("Include MenuBar in Recording") }
                             .padding([.leading, .trailing], 10)
                             .toggleStyle(.checkbox)
                             .disabled(isMacOS12)
                        Toggle(isOn: $highlightMouse) { Text("Highlight the Mouse Cursor") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                        //.onChange(of: highlightMouse) {_ in Task { if highlightMouse { hideSelf = false }}}
                        Text("Not available for \"Single Window Capture\"")
                            .font(.footnote).foregroundColor(Color.gray).padding([.leading,.trailing], 6).padding(.top, -5).fixedSize(horizontal: false, vertical: true)
                        Toggle(isOn: $hideDesktopFiles) { Text("Exclude the \"Desktop Files\" layer") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                        Text("If enabled, all files on the Desktop will be hidden from the video when recording.")
                            .font(.footnote).foregroundColor(Color.gray).padding([.leading,.trailing, .bottom], 6).padding(.top, -5).fixedSize(horizontal: false, vertical: true)
                        
                    }
                }.frame(width: 270)
            }
            HStack(alignment: .top, spacing: 17){
                GroupBox(label: Text("Shortcuts Settings".local).fontWeight(.bold)) {
                    Form(){
                        KeyboardShortcuts.Recorder("Stop Recording", name: .stop)
                        KeyboardShortcuts.Recorder("Pause / Resume", name: .pauseResume)
                        KeyboardShortcuts.Recorder("Record System Audio", name: .startWithAudio)
                        KeyboardShortcuts.Recorder("Record Current Screen", name: .startWithScreen)
                        KeyboardShortcuts.Recorder("Record Topmost Window", name: .startWithWindow)
                        KeyboardShortcuts.Recorder("Select Area to Record", name: .startWithArea)
                        KeyboardShortcuts.Recorder("Save Current Frame", name: .saveFrame)
                        KeyboardShortcuts.Recorder("Toggle Screen Magnifier", name: .screenMagnifier)
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).padding(6)
                }.frame(width: 320).fixedSize()
                GroupBox(label: Text("Excluded Apps".local).fontWeight(.bold)) {
                    VStack(spacing: 5.5) {
                        BundleSelector()
                        Text("These apps will be excluded when recording \"Screen\" or \"Screen Area\"\n* But if the app is launched after the recording starts, it cannot be excluded.")
                            .font(.footnote).foregroundColor(Color.gray).padding([.leading,.trailing], 0).fixedSize(horizontal: false, vertical: true)
                    }
                }.frame(width: 220)
            }
            HStack(alignment: .top, spacing: 17) {
                ZStack(alignment: .bottomTrailing){
                    GroupBox(label: Text("Update Settings".local).fontWeight(.bold)) {
                        Form(){
                            UpdaterSettingsView(updater: updaterController.updater)
                        }.frame(maxWidth: .infinity).padding([.top, .bottom], 5)
                        Button(action: {
                            updaterController.updater.checkForUpdates()
                        }) {
                            Text("Check for Updates")
                        }
                    }
                }.frame(width: 320)
                GroupBox(label: Text("Icon Settings".local).fontWeight(.bold)) {
                    Form(){
                        Toggle(isOn: $showOnDock) { Text("Show Dock Icon") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                            .disabled(!showMenubar)
                            .onChange(of: showOnDock) { newValue in
                                if !newValue { NSApp.setActivationPolicy(.accessory) } else { NSApp.setActivationPolicy(.regular) }
                            }
                        Toggle(isOn: $showMenubar) { Text("Show MenuBar Icon") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                            .disabled(!showOnDock)
                            .onChange(of: showMenubar) { _ in appDelegate.updateStatusBar() }
                        Toggle(isOn: $miniStatusBar) { Text("Use Mini Controller") }
                            .padding([.leading, .trailing], 10)
                            .toggleStyle(.checkbox)
                    }.frame(maxWidth: .infinity).padding([.top, .bottom], 5)
                }.frame(width: 220)
            }
            Divider()
            HStack {
                HStack(spacing: 10) {
                    Button(action: {
                        updateOutputDirectory()
                    }, label: {
                        Text("change-path").padding([.leading, .trailing], 6)
                    })
                    Text(String(format: "\"%@\"".local, saveDirectory!))
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: 170)
                }.padding(.leading, 0.5)
                Spacer()
                if #available(macOS 13, *) {
                    VStack {
                        HStack(spacing: 10){
                            Toggle(isOn: $launchAtLogin) {}
                                .toggleStyle(.switch)
                                .onChange(of: launchAtLogin) { newValue in
                                    do {
                                        if newValue {
                                            try SMAppService.mainApp.register()
                                        } else {
                                            try SMAppService.mainApp.unregister()
                                        }
                                    }catch{
                                        print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
                                    }
                                }
                            Text("Launch at login").padding(.leading, -5)
                        }
                    }
                }
                
            }.padding(.top, 1.5)
        }
        .padding([.leading, .trailing], 17).padding([.top, .bottom], 12)
        .onAppear{
            userColor = ud.color(forKey: "userColor") ?? Color.black
            if #available(macOS 13, *) { launchAtLogin = (SMAppService.mainApp.status == .enabled) }
        }
    }
    
    func updateOutputDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowedContentTypes = []
        openPanel.allowsOtherFileTypes = false
        openPanel.directoryURL = URL(fileURLWithPath: saveDirectory!) // 打开当前设置的目录
        openPanel.allowsMultipleSelection = false
        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            if let path = openPanel.urls.first?.path { saveDirectory = path }
        }
    }
    
    func getVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown".local
    }

    func getBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown".local
    }
}

extension UserDefaults {
    func setColor(_ color: Color?, forKey key: String) {
        guard let color = color else {
            removeObject(forKey: key)
            return
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(color), requiringSecureCoding: false)
            set(data, forKey: key)
        } catch {
            print("Error archiving color:", error)
        }
    }
    
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key),
              let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            return nil
        }
        return Color(nsColor)
    }
    
    func cgColor(forKey key: String) -> CGColor? {
        guard let data = data(forKey: key),
              let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            return nil
        }
        return nsColor.cgColor
    }
}

extension KeyboardShortcuts.Name {
    static let startWithAudio = Self("startWithAudio")
    static let startWithScreen = Self("startWithScreen")
    static let startWithWindow = Self("startWithWindow")
    static let startWithArea = Self("startWithArea")
    static let screenMagnifier = Self("screenMagnifier")
    static let saveFrame = Self("saveFrame")
    static let pauseResume = Self("pauseResume")
    static let stop = Self("stop")
}

extension AppDelegate {
    
//     这个方法似乎并么有执行
    @available(macOS 13.0, *)
    @objc func setLoginItem(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        do {
            if sender.state == .on { try SMAppService.mainApp.register() }
            if sender.state == .off { try SMAppService.mainApp.unregister() }
        }catch{
            print("Failed to \(sender.state == .on ? "enable" : "disable") launch at login: \(error.localizedDescription)")
        }
    }
}
