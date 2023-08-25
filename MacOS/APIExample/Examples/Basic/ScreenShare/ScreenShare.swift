//
//  JoinChannelVC.swift
//  APIExample
//
//  Created by 张乾泽 on 2020/4/17.
//  Copyright © 2020 Agora Corp. All rights reserved.
//
import Cocoa
import AgoraRtcKit
import AGEVideoLayout

class ScreenShare: BaseViewController {
    var videos: [VideoView] = []
    
    @IBOutlet weak var container: AGEVideoContainer!
    
    var agoraKit: AgoraRtcEngineKit!
    
    var currentCameraId: String = ""
    
    let screenShare1Uid: UInt = 11111
    let cameraUid: UInt = 22222
    let screenShare2Uid: UInt = 33333
    
    let cameraConnection = AgoraRtcConnection()
    
    let screenShare1Resolution = Configs.Resolutions[3]
    let screenShare1Fps = Configs.Fps[2]
    
    let screenShare2Resolution = Configs.Resolutions[4]
    let screenShare2Fps =  Configs.Fps[2]
    
    @IBOutlet weak var channel1TextField: NSTextField!
    @IBOutlet weak var joinChannel1Button: NSButton!
    @IBOutlet weak var cameraButton: NSButton!
    @IBOutlet weak var screenShare1Button: NSButton!
    
    @IBOutlet weak var channel2TextField: NSTextField!
    @IBOutlet weak var joinChannel2Button: NSButton!
    @IBOutlet weak var screenShare2Button: NSButton!
    
    @IBOutlet weak var channel1ScreenList: NSPopUpButton!
    @IBOutlet weak var channel2ScreenList: NSPopUpButton!
    @IBOutlet weak var roleSelectList: NSPopUpButton!
    
    var windowManager: WindowList = WindowList()
    
    var channel1SelectedScreen: Window?
    var channel2SelectedScreen: Window?
    
    
    @IBAction func roleSelected(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            channel1ScreenList.superview?.isHidden = false
            channel2ScreenList.superview?.isHidden = false
        } else if sender.indexOfSelectedItem == 1 {
            channel1ScreenList.superview?.isHidden = true
            channel2ScreenList.superview?.isHidden = true
        }
    }
    
    @IBAction func startScreenShare1(_ sender: NSButton) {
        guard let screen = channel1SelectedScreen else {
            return
        }
        
        let params = AgoraScreenCaptureParameters()
        params.frameRate = screenShare1Fps
        params.dimensions = screenShare1Resolution.size()
        // 增加勾边功能
        params.highLightWidth = 3
        params.highLightColor = .purple
        params.highLighted = true
        
        let result = agoraKit.startScreenCapture(byDisplayId: screen.id, regionRect: .zero, captureParams: params)
        if result == 0 {
            let mediaOptions = AgoraRtcChannelMediaOptions()
            mediaOptions.publishScreenTrack = true
            mediaOptions.clientRoleType = .broadcaster
            agoraKit.updateChannel(with: mediaOptions)
            LogUtils.log(message: "1080p screen user join: \(self.screenShare1Uid) ", level: .info)
            startPreviewScreenSharing()
        } else {
            self.showAlert(title: "Error", message: "startScreenCapture call failed: \(result), please check your params")
        }
        
    }
    
    
    @IBAction func start720CameraCapture(_ sender: NSButton) {
        let channel = "channelField.stringValue"
        if channel.isEmpty {
            return
        }
        
        let channel1 = channel1TextField.stringValue
        if channel1.isEmpty {
            return
        }
        
        let mediaOptions = AgoraRtcChannelMediaOptions()
        mediaOptions.publishCameraTrack = true
        mediaOptions.publishMicrophoneTrack = true
        mediaOptions.autoSubscribeAudio = false
        mediaOptions.autoSubscribeVideo = false
        mediaOptions.clientRoleType = .broadcaster
        
        cameraConnection.channelId = channel1
        cameraConnection.localUid = self.cameraUid
        NetworkManager.shared.generateToken(channelName: channel, uid: self.cameraUid) { token in
            let result = self.agoraKit.joinChannelEx(byToken: token,
                                                     connection: self.cameraConnection,
                                                     delegate: self,
                                                     mediaOptions: mediaOptions)
            
            if result != 0 {
                self.showAlert(title: "Error", message: "joinChannel with second uid call failed: \(result), please check your params")
            } else {
                LogUtils.log(message: "720p camera user join: \(self.cameraUid) ", level: .info)
                let captureConfig = AgoraCameraCapturerConfiguration()
                captureConfig.deviceId = self.currentCameraId
                captureConfig.dimensions = CGSize(width: 1280, height: 720)
                captureConfig.frameRate = 30
                self.agoraKit.startCameraCapture(.camera, config: captureConfig)
                
                if let nextVideoPlaceView = self.videos.first(where: { $0.uid == nil }) {
                    nextVideoPlaceView.uid = self.cameraUid
                    let videoCanvas = AgoraRtcVideoCanvas()
                    videoCanvas.sourceType = .camera
                    videoCanvas.renderMode = .hidden
                    videoCanvas.uid = self.cameraUid
                    // the view to be binded
                    videoCanvas.view = nextVideoPlaceView
                    self.agoraKit.setupLocalVideo(videoCanvas)
                    self.agoraKit.startPreview(.camera)
                }
            }
        }
    }
    
    
    @IBAction func startScreenSharing2(_ sender: NSButton) {
        guard let screen = channel2SelectedScreen else {
            return
        }
        
        let channel2 = channel2TextField.stringValue
        if channel2.isEmpty {
            return
        }
        
        let screenShare2Conn = AgoraRtcConnection()
        screenShare2Conn.localUid = screenShare2Uid
        screenShare2Conn.channelId = channel2
        
        let params = AgoraScreenCaptureParameters()
        params.frameRate = screenShare2Fps
        params.dimensions = screenShare2Resolution.size()
        
        // 增加勾边功能
        params.highLightWidth = 3
        params.highLightColor = .purple
        params.highLighted = true
        
        let screenConfig = AgoraScreenCaptureConfiguration()
        screenConfig.displayId = UInt32(screen.id)
        screenConfig.isCaptureWindow = false
        screenConfig.params = params
        
        let result = self.agoraKit.startScreenCapture(.screenSecondary, config: screenConfig)
        if result != 0 {
            self.showAlert(title: "Error", message: "startScreenCapture call failed: \(result), please check your params")
        } else {
            let mediaOptions = AgoraRtcChannelMediaOptions()
            mediaOptions.publishCameraTrack = false
            mediaOptions.publishSecondaryScreenTrack = true
            mediaOptions.clientRoleType = .broadcaster
            agoraKit.updateChannelEx(with: mediaOptions, connection: screenShare2Conn)
            
            
            let nextVideoPlaceView = self.videos[2]
            nextVideoPlaceView.uid = screenShare2Conn.localUid
            
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.mirrorMode = .disabled
            videoCanvas.sourceType = .screenSecondary
            videoCanvas.renderMode = .hidden
            videoCanvas.uid = screenShare2Conn.localUid
            // the view to be binded
            videoCanvas.view = nextVideoPlaceView
            self.agoraKit.setupLocalVideo(videoCanvas)
            self.agoraKit.startPreview(.screenSecondary)
        }
    }
    
    var isChannel1Joined: Bool = false {
        didSet {
            joinChannel1Button.isEnabled = !isChannel1Joined
            channel1TextField.isEnabled = !isChannel1Joined
            cameraButton.isEnabled = isChannel1Joined
            screenShare1Button.isEnabled = isChannel1Joined
        }
    }
    
    var isChannel2Joined: Bool = false {
        didSet {
            joinChannel2Button.isEnabled = !isChannel2Joined
            channel2TextField.isEnabled = !isChannel2Joined
            screenShare2Button.isEnabled = isChannel2Joined
        }
    }
    
    var isProcessingChannel1: Bool = false {
        didSet {
             joinChannel1Button.isEnabled = !isProcessingChannel1
        }
    }
    
    var isProcessingChannel2: Bool = false {
        didSet {
            joinChannel2Button.isEnabled = !isProcessingChannel2
        }
    }
    
    
    @IBAction func channel1SelectScreen(_ sender: NSPopUpButton) {
        let screenlist = windowManager.items.filter({$0.type == .screen})
        self.channel1SelectedScreen = screenlist[sender.indexOfSelectedItem]
    }
    
    @IBAction func channel2SelectScreen(_ sender: NSPopUpButton) {
        let screenlist = windowManager.items.filter({$0.type == .screen})
        self.channel2SelectedScreen = screenlist[sender.indexOfSelectedItem]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        layoutVideos(4)
        screenShare1Button.isEnabled = false
        cameraButton.isEnabled = false
        screenShare2Button.isEnabled = false
        
        // prepare window manager and list
        windowManager.getList()
        
        let screens = windowManager.items.filter({$0.type == .screen})
        self.channel1SelectedScreen = screens[0]
        self.channel2SelectedScreen = screens[0]
        channel1ScreenList.addItems(withTitles: screens.map { $0.name })
        channel2ScreenList.addItems(withTitles: screens.map { $0.name })

        // Do view setup here.
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // Configuring Privatization Parameters
        Util.configPrivatization(agoraKit: agoraKit)
        agoraKit.enableVideo()
        
        initCameraDevice()
    }
    
    
    func initCameraDevice() {
        // find device in a separate thread to avoid blocking main thread
        let queue = DispatchQueue(label: "device.enumerateDevices")
        queue.async {[unowned self] in
            let cameras: [AgoraRtcDeviceInfo] = self.agoraKit.enumerateDevices(.videoCapture) ?? []
            // use 0 index devices
            guard let cameraId = cameras[0].deviceId else {
                return
            }
            currentCameraId = cameraId
            self.agoraKit.setDevice(.videoCapture, deviceId: cameraId)
        }
    }
    
    override func viewWillBeRemovedFromSplitView() {
        leave(NSButton())
        AgoraRtcEngineKit.destroy()
    }
    
    @IBAction func onJoinChannel1(_ sender: Any) {
        if isProcessingChannel1 { return }
        if isChannel1Joined { return }
        
        let channel = channel1TextField.stringValue
        if channel.isEmpty {
            return
        }
        
        agoraKit.setChannelProfile(.communication)
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: screenShare1Resolution.size(),
                frameRate: AgoraVideoFrameRate(rawValue: screenShare1Fps) ?? .fps30,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative,
                mirrorMode: .auto
            )
        )
        
        isProcessingChannel1 = true
        
        let option = AgoraRtcChannelMediaOptions()
        option.publishCameraTrack = false
        option.autoSubscribeAudio = true
        option.autoSubscribeVideo = true
        option.clientRoleType = .broadcaster
        NetworkManager.shared.generateToken(channelName: channel, success: { token in
            let result = self.agoraKit.joinChannel(byToken: token,
                                                   channelId: channel,
                                                   uid: self.screenShare1Uid,
                                                   mediaOptions: option)
            self.isProcessingChannel1 = false
            if result != 0 {
                self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
            } else {
                self.isChannel1Joined = true
            }
        })
    }
    
    
    @IBAction func onJoinChannel2(_ sender: Any) {
        if isProcessingChannel2 { return }
        if isChannel2Joined { return }
        
        let channel2 = channel2TextField.stringValue
        if channel2.isEmpty {
            return
        }

        let mediaOptions = AgoraRtcChannelMediaOptions()
        mediaOptions.publishCameraTrack = false
        mediaOptions.publishScreenTrack = false
        mediaOptions.publishSecondaryScreenTrack = true
        mediaOptions.autoSubscribeAudio = false
        mediaOptions.autoSubscribeVideo = false
        
        isProcessingChannel2 = true
        
        let screenShare2Conn = AgoraRtcConnection()
        screenShare2Conn.localUid = screenShare2Uid
        screenShare2Conn.channelId = channel2
        NetworkManager.shared.generateToken(channelName: screenShare2Conn.channelId, uid: screenShare2Conn.localUid) { token in
            let result = self.agoraKit.joinChannelEx(byToken: token,
                                                     connection: screenShare2Conn,
                                                     delegate: self,
                                                     mediaOptions: mediaOptions)
            
            self.isProcessingChannel2 = false
            if result != 0 {
                self.showAlert(title: "Error", message: "joinChannel with second uid call failed: \(result), please check your params")
            } else {
                self.isChannel2Joined = true
            }
        }
    }
    
    
    @IBAction func leave(_ sender: NSButton) {
        if isChannel1Joined {
            agoraKit.stopCameraCapture(.camera)
            agoraKit.stopScreenCapture(.screen)
            
            agoraKit.leaveChannel { [unowned self] (stats:AgoraChannelStats) in
                agoraKit.leaveChannelEx(cameraConnection)
                self.isChannel1Joined = false
                self.videos.forEach {
                    $0.uid = nil
                    $0.statsLabel.stringValue = ""
                }
            }
            LogUtils.log(message: "Left channel1", level: .info)
        }
        
        if isChannel2Joined {
            agoraKit.stopScreenCapture(.screenSecondary)
            
            let screenShare2Conn = AgoraRtcConnection()
            screenShare2Conn.localUid =  screenShare2Uid
            screenShare2Conn.channelId = channel2TextField.stringValue
            agoraKit.leaveChannelEx(screenShare2Conn)
            self.isChannel2Joined = false
        }
    }
    
    
    func startPreviewScreenSharing() {
        if let unPlacedView = videos.first(where: { $0.uid == nil }) {
            unPlacedView.uid = screenShare1Uid
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = screenShare1Uid
            videoCanvas.view = unPlacedView.videocanvas
            videoCanvas.renderMode = .hidden
            videoCanvas.sourceType = .screen
            videoCanvas.mirrorMode = .disabled
            agoraKit.setupLocalVideo(videoCanvas)
            agoraKit.startPreview()
        }
    }
    
    func layoutVideos(_ count: Int) {
        videos = []
        for i in 0...count - 1 {
            let view = VideoView.createFromNib()!
            if(i == 0) {
                view.placeholder.stringValue = "Local"
            } else {
                view.placeholder.stringValue = "Remote \(i)"
            }
            videos.append(view)
        }
        // layout render view
        container.layoutStream(views: videos)
    }
}

/// agora rtc engine delegate events
extension ScreenShare: AgoraRtcEngineDelegate {
    /// callback when warning occured for agora sdk, warning can usually be ignored, still it's nice to check out
    /// what is happening
    /// Warning code description can be found at:
    /// en: https://api-ref.agora.io/en/voice-sdk/ios/3.x/Constants/AgoraWarningCode.html
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraWarningCode.html
    /// @param warningCode warning code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        LogUtils.log(message: "warning: \(warningCode.rawValue)", level: .warning)
    }
    
    /// callback when error occured for agora sdk, you are recommended to display the error descriptions on demand
    /// to let user know something wrong is happening
    /// Error code description can be found at:
    /// en: https://api-ref.agora.io/en/voice-sdk/macos/3.x/Constants/AgoraErrorCode.html#content
    /// cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
    /// @param errorCode error code of the problem
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        LogUtils.log(message: "error: \(errorCode)", level: .error)
        if isProcessingChannel1 {
            isProcessingChannel1 = false
        }
        self.showAlert(title: "Error", message: "Error \(errorCode.rawValue) occur")
    }
    
    /// callback when the local user joins a specified channel.
    /// @param channel
    /// @param uid uid of local user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        //        isProcessing = false
        //        isJoined = true
        //        videos[0].uid = self.screenShare1Uid
        LogUtils.log(message: "local user join \(channel) with uid \(uid) elapsed \(elapsed)ms", level: .info)
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "remote user join: \(uid) \(elapsed)ms", level: .info)
        
        // find a VideoView w/o uid assigned
        if let remoteVideo = videos.first(where: { $0.uid == nil }) {
            //            remoteVideo.uid = uid
            //
            //            let videoCanvas = AgoraRtcVideoCanvas()
            //            videoCanvas.uid = uid
            //            videoCanvas.view = remoteVideo.videocanvas
            //            videoCanvas.renderMode = .hidden
            //            agoraKit.setupRemoteVideo(videoCanvas)
            
        } else {
            LogUtils.log(message: "no video canvas available for \(uid), cancel bind", level: .warning)
        }
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        LogUtils.log(message: "remote user left: \(uid) reason \(reason)", level: .info)
        
        if let remoteVideo = videos.first(where: { $0.uid == uid }) {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            // the view to be binded
            videoCanvas.view = nil
            videoCanvas.renderMode = .hidden
            agoraKit.setupRemoteVideo(videoCanvas)
            remoteVideo.uid = nil
        } else {
            LogUtils.log(message: "no matching video canvas for \(uid), cancel unbind", level: .warning)
        }
    }
    
}
