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

struct SuperResolution: Codable {
    let uid: Int
    let type: Int
}

class JoinChannelVideoMain: BaseViewController, NSWindowDelegate {
    
    var agoraKit: AgoraRtcEngineKit!
    var remoteUid: UInt = 0
    
    var videos: [VideoView] = []
    @IBOutlet weak var Container: AGEVideoContainer!

    let setVc = AdvancedSettingController()

    let videoEncoderConfig = AgoraVideoEncoderConfiguration()

    lazy var captureConfig: AgoraCameraCapturerConfiguration = {
        let config = AgoraCameraCapturerConfiguration()
        config.dimensions = CGSize(width: 1280, height: 720)
        config.frameRate = 15
        return config
    }()
    

    /**
     --- Cameras Picker ---
     */
    @IBOutlet weak var selectCameraPicker: Picker!
    var cameras: [AgoraRtcDeviceInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                self.selectCameraPicker.picker.addItems(withTitles: self.cameras.map {$0.deviceName ?? "unknown"})
            }
        }
    }
    var selectedCamera: AgoraRtcDeviceInfo? {
        let index = selectCameraPicker.indexOfSelectedItem
        if index >= 0 && index < cameras.count {
            return cameras[index]
        } else {
            return nil
        }
    }
    func initSelectCameraPicker() {
        selectCameraPicker.label.stringValue = "Camera".localized
        // find device in a separate thread to avoid blocking main thread
        let queue = DispatchQueue(label: "device.enumerateDevices")
        queue.async {[unowned self] in
            self.cameras = self.agoraKit.enumerateDevices(.videoCapture) ?? []
        }
        
        selectCameraPicker.onSelectChanged {
            if !self.isJoined {
                return
            }
            // use selected devices
            guard let cameraId = self.selectedCamera?.deviceId else {
                return
            }
            self.agoraKit.setDevice(.videoCapture, deviceId: cameraId)
        }
    }
    
    /**
     --- Resolutions Picker ---
     */
    @IBOutlet weak var selectResolutionPicker: Picker!
    var selectedResolution: Resolution? {
        let index = self.selectResolutionPicker.indexOfSelectedItem
        if index >= 0 && index < Configs.Resolutions.count {
            return Configs.Resolutions[index]
        } else {
            return nil
        }
    }
    func initSelectResolutionPicker() {
        selectResolutionPicker.label.stringValue = "Resolution".localized
        selectResolutionPicker.picker.addItems(withTitles: Configs.Resolutions.map { $0.name() })
        selectResolutionPicker.picker.selectItem(at: GlobalSettings.shared.resolutionSetting.selectedOption().value)
        
        selectResolutionPicker.onSelectChanged {
            if !self.isJoined {
                return
            }
            
            guard let resolution = self.selectedResolution,
                  let fps = self.selectedFps else {
                return
            }
            
            self.videoEncoderConfig.dimensions = resolution.size()
            self.videoEncoderConfig.frameRate =  AgoraVideoFrameRate(rawValue: fps) ?? .fps15
            self.videoEncoderConfig.bitrate = AgoraVideoBitrateStandard
            self.videoEncoderConfig.orientationMode = .adaptative
            self.videoEncoderConfig.mirrorMode = AgoraVideoMirrorMode.auto
            self.agoraKit.setVideoEncoderConfiguration(self.videoEncoderConfig)
        }
    }
    
    /**
     --- Fps Picker ---
     */
    @IBOutlet weak var selectFpsPicker: Picker!
    var selectedFps: Int? {
        let index = self.selectFpsPicker.indexOfSelectedItem
        if index >= 0 && index < Configs.Fps.count {
            return Configs.Fps[index]
        } else {
            return nil
        }
    }
    func initSelectFpsPicker() {
        selectFpsPicker.label.stringValue = "Frame Rate".localized
        selectFpsPicker.picker.addItems(withTitles: Configs.Fps.map { "\($0)fps" })
        selectFpsPicker.picker.selectItem(at: GlobalSettings.shared.fpsSetting.selectedOption().value)
        
        selectFpsPicker.onSelectChanged {
            if !self.isJoined {
                return
            }
            
            guard let resolution = self.selectedResolution,
                  let fps = self.selectedFps else {
                return
            }
            self.agoraKit.setVideoEncoderConfiguration(
                AgoraVideoEncoderConfiguration(
                    size: resolution.size(),
                    frameRate: AgoraVideoFrameRate(rawValue: fps) ?? .fps15,
                    bitrate: AgoraVideoBitrateStandard,
                    orientationMode: .adaptative,
                    mirrorMode: .auto
                )
            )
        }
    }
    
    /**
     --- Microphones Picker ---
     */
    @IBOutlet weak var selectMicsPicker: Picker!
    var mics: [AgoraRtcDeviceInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                self.selectMicsPicker.picker.addItems(withTitles: self.mics.map {$0.deviceName ?? "unknown"})
            }
        }
    }
    var selectedMicrophone: AgoraRtcDeviceInfo? {
        let index = self.selectMicsPicker.indexOfSelectedItem
        if index >= 0 && index < mics.count {
            return mics[index]
        } else {
            return nil
        }
    }
    func initSelectMicsPicker() {
        selectMicsPicker.label.stringValue = "Microphone".localized
        // find device in a separate thread to avoid blocking main thread
        let queue = DispatchQueue(label: "device.enumerateDevices")
        queue.async {[unowned self] in
            self.mics = self.agoraKit.enumerateDevices(.audioRecording) ?? []
        }
        
        selectMicsPicker.onSelectChanged {
            if !self.isJoined {
                return
            }
            // use selected devices
            guard let micId = self.selectedMicrophone?.deviceId else {
                return
            }
            self.agoraKit.setDevice(.audioRecording, deviceId: micId)
        }
    }
    
    /**
     --- Layout Picker ---
     */
    @IBOutlet weak var selectLayoutPicker: Picker!
    let layouts = [Layout("1v1", 2), Layout("1v3", 4), Layout("1v8", 9), Layout("1v15", 16)]
    var selectedLayout: Layout? {
        let index = self.selectLayoutPicker.indexOfSelectedItem
        if index >= 0 && index < layouts.count {
            return layouts[index]
        } else {
            return nil
        }
    }
    func initSelectLayoutPicker() {
        layoutVideos(2)
        selectLayoutPicker.label.stringValue = "Layout".localized
        selectLayoutPicker.picker.addItems(withTitles: layouts.map { $0.label })
        selectLayoutPicker.onSelectChanged {
            if self.isJoined {
                return
            }
            guard let layout = self.selectedLayout else { return }
            self.layoutVideos(layout.value)
        }
    }
    
    /**
     --- Role Picker ---
     */
    @IBOutlet weak var selectRolePicker: Picker!
    private let roles = AgoraClientRole.allValues()
    var selectedRole: AgoraClientRole? {
        let index = self.selectRolePicker.indexOfSelectedItem
        if index >= 0 && index < roles.count {
            return roles[index]
        } else {
            return nil
        }
    }
    func initSelectRolePicker() {
        selectRolePicker.label.stringValue = "Role".localized
        selectRolePicker.picker.addItems(withTitles: roles.map { $0.description() })
        selectRolePicker.onSelectChanged {
            guard let selected = self.selectedRole else { return }
            if self.isJoined {
                self.agoraKit.setClientRole(selected)
            }
        }
    }
    
    /**
     --- Channel TextField ---
     */
    @IBOutlet weak var channelField: Input!
    func initChannelField() {
        channelField.label.stringValue = "Channel".localized
        channelField.field.placeholderString = "Channel Name".localized
    }
    
    /**
     --- Button ---
     */
    @IBOutlet weak var joinChannelButton: NSButton!
    func initJoinChannelButton() {
        joinChannelButton.title = isJoined ? "Leave Channel".localized : "Join Channel".localized
    }
    
    // indicate if current instance has joined channel
    var isJoined: Bool = false {
        didSet {
            channelField.isEnabled = !isJoined
            selectLayoutPicker.isEnabled = !isJoined
            initJoinChannelButton()
        }
    }
    
    // indicate for doing something
    var isProcessing: Bool = false {
        didSet {
            joinChannelButton.isEnabled = !isProcessing
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area
        config.eventDelegate = self
                
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        // Configuring Privatization Parameters
        Util.configPrivatization(agoraKit: agoraKit)
        
        agoraKit.setParameters("{\"rtc.debug.enable\": true}");
        agoraKit.setParameters("{\"che.audio.apm_dump\":true}");
        agoraKit.setParameters("{\"che.audio.frame_dump\":{\"location\":\"all\",\"action\":\"start\",\"max_size_bytes\":\"120000000\",\"uuid\":\"123456789\",\"duration\":\"1200000\"}}");
        
        agoraKit.enableVideo()
        
        initSelectCameraPicker()
        initSelectResolutionPicker()
        initSelectFpsPicker()
        initSelectMicsPicker()
        initSelectLayoutPicker()
        initSelectRolePicker()
        initChannelField()
        initJoinChannelButton()
        remoteUid = 0
    }

    func layoutVideos(_ count: Int) {
        videos = []
        for i in 0...count - 1 {
            let view = VideoView.createFromNib()!
            if(i == 0) {
                view.placeholder.stringValue = "Local"
                view.type = .local
                view.statsInfo = StatisticsInfo(type: .local(StatisticsInfo.LocalInfo()))
            } else {
                view.placeholder.stringValue = "Remote \(i)"
                view.type = .remote
                view.statsInfo = StatisticsInfo(type: .remote(StatisticsInfo.RemoteInfo()))
            }
            videos.append(view)
        }
        // layout render view
        Container.layoutStream(views: videos)
    }
    
    @IBAction func onVideoCallButtonPressed(_ sender: NSButton) {
        if !isJoined {
            // check configuration
            let channel = channelField.stringValue
            if channel.isEmpty {
                return
            }
            guard let cameraId = selectedCamera?.deviceId,
                  let resolution = selectedResolution,
                  let micId = selectedMicrophone?.deviceId,
                  let role = selectedRole,
                  let fps = selectedFps else {
                return
            }
            
            // set proxy configuration
//            let proxySetting = GlobalSettings.shared.proxySetting.selectedOption().value
//            agoraKit.setCloudProxy(AgoraCloudProxyType.init(rawValue: UInt(proxySetting)) ?? .noneProxy)
            
            agoraKit.setDevice(.videoCapture, deviceId: cameraId)
            agoraKit.setDevice(.audioRecording, deviceId: micId)
            // set myself as broadcaster to stream video/audio
            agoraKit.setClientRole(role)
            agoraKit.setVideoEncoderConfiguration(
                AgoraVideoEncoderConfiguration(
                    size: resolution.size(),
                    frameRate: AgoraVideoFrameRate(rawValue: fps) ?? .fps15,
                    bitrate: AgoraVideoBitrateStandard,
                    orientationMode: .adaptative,
                    mirrorMode: .auto
                )
            )
            
            // set up local video to render your local camera preview
            let localVideo = videos[0]
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = 0
            // the view to be binded
            videoCanvas.view = localVideo.videocanvas
            videoCanvas.renderMode = .hidden
            agoraKit.setupLocalVideo(videoCanvas)
            // you have to call startPreview to see local video
            agoraKit.startPreview()
            
            // start joining channel
            // 1. Users can only see each other after they join the
            // same channel successfully using the same app id.
            // 2. If app certificate is turned on at dashboard, token is needed
            // when joining channel. The channel name and uid used to calculate
            // the token has to match the ones used for channel join
            isProcessing = true
            let option = AgoraRtcChannelMediaOptions()
            option.publishCameraTrack = role == .broadcaster
            option.clientRoleType = role
            NetworkManager.shared.generateToken(channelName: channel, success: { token in
                let result = self.agoraKit.joinChannel(byToken: token, channelId: channel, uid: 0, mediaOptions: option)
                if result != 0 {
                    self.isProcessing = false
                    // Usually happens with invalid parameters
                    // Error code description can be found at:
                    // en: https://api-ref.agora.io/en/voice-sdk/macos/3.x/Constants/AgoraErrorCode.html#content
                    // cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
                    self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
                }
            })
        } else {
            isProcessing = true
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = 0
            // the view to be binded
            videoCanvas.view = nil
            videoCanvas.renderMode = .hidden
            agoraKit.setupLocalVideo(videoCanvas)
            agoraKit.leaveChannel { (stats:AgoraChannelStats) in
                LogUtils.log(message: "Left channel", level: .info)
                self.isProcessing = false
                self.videos[0].uid = nil
                self.isJoined = false
                self.videos.forEach {
                    $0.uid = nil
                    $0.statsLabel.stringValue = ""
                }
            }
        }
    }
    
    
    @IBAction func supperSets(_ sender: NSButton) {
        if !isJoined {
            return self.showAlert(title: "Error", message: "please set after join channal")
        }
        let rewin = setVc.realWindow()
        rewin?.onSetDelegate = self
        self.view.window?.addChildWindow(setVc.window!, ordered: .above)
    }
    
    override func viewWillBeRemovedFromSplitView() {
        if isJoined {
            agoraKit.disableVideo()
            agoraKit.leaveChannel { (stats:AgoraChannelStats) in
                LogUtils.log(message: "Left channel", level: .info)
            }
        }
        AgoraRtcEngineKit.destroy()
    }
    

    
    private var dimensionsItems: [CGSize] {
        ShowAgoraVideoDimensions.allCases.map({$0.sizeValue})
    }
    
    private var captureDimensionsItems: [CGSize] {
        ShowAgoraCaptureVideoDimensions.allCases.map({$0.sizeValue})
    }
    
    /// 设置265
    /// - Parameter isOn: 开关
    func setH265On(_ isOn: Bool) {
        agoraKit.setParameters("{\"engine.video.enable_hw_encoder\":\(isOn)}")
        agoraKit.setParameters("{\"engine.video.codec_type\":\"\(isOn ? 3 : 2)\"}")
    }
    
}

/// agora rtc engine delegate events
extension JoinChannelVideoMain: AgoraRtcEngineDelegate {
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
        if self.isProcessing {
            self.isProcessing = false
        }
        self.showAlert(title: "Error", message: "Error \(errorCode.rawValue) occur")
    }
    
    /// callback when the local user joins a specified channel.
    /// @param channel
    /// @param uid uid of local user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        isProcessing = false
        isJoined = true
        let localVideo = videos[0]
        localVideo.uid = uid
        LogUtils.log(message: "Join \(channel) with uid \(uid) elapsed \(elapsed)ms", level: .info)
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "remote user join: \(uid) \(elapsed)ms", level: .info)
        
        // find a VideoView w/o uid assigned
        if let remoteVideo = videos.first(where: { $0.uid == nil }) {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            // the view to be binded
            videoCanvas.view = remoteVideo.videocanvas
            videoCanvas.renderMode = .hidden
            agoraKit.setupRemoteVideo(videoCanvas)
            remoteVideo.uid = uid
            remoteUid = uid
        } else {
            LogUtils.log(message: "no video canvas available for \(uid), cancel bind", level: .warning)
            remoteUid = 0
        }
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        LogUtils.log(message: "remote user left: \(uid) reason \(reason)", level: .info)
        
        // to unlink your view from sdk, so that your view reference will be released
        // note the video will stay at its last frame, to completely remove it
        // you will need to remove the EAGL sublayer from your binded view
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
        remoteUid = 0
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        videos[0].statsInfo?.updateChannelStats(stats)
    }
    
    /// Reports the statistics of the uploading local video streams once every two seconds.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStats stats: AgoraRtcLocalVideoStats, sourceType:AgoraVideoSourceType) {
        videos[0].statsInfo?.updateLocalVideoStats(stats)
    }
    
    /// Reports the statistics of the uploading local audio streams once every two seconds.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStats stats: AgoraRtcLocalAudioStats) {
        videos[0].statsInfo?.updateLocalAudioStats(stats)
    }
    
    /// Reports the statistics of the video stream from each remote user/host.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        videos.first(where: { $0.uid == stats.uid })?.statsInfo?.updateVideoStats(stats)
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    /// @param stats stats struct for current call statistics
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        videos.first(where: { $0.uid == stats.uid })?.statsInfo?.updateAudioStats(stats)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStateChangedOf state: AgoraVideoLocalState, error: AgoraLocalVideoStreamError, sourceType:AgoraVideoSourceType) {
        LogUtils.log(message: "AgoraRtcEngineKit state: \(state), error \(error)", level: .info)
    }
}


extension JoinChannelVideoMain: AgoraMediaFilterEventDelegate{
    func onEvent(_ provider: String?, extension: String?, key: String?, value: String?) {
        if let srKey = key, srKey == "sr_type" {
            if let jsonData = value?.data(using: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    let superResolution = try decoder.decode(SuperResolution.self, from: jsonData)
                    let videoView = videos.filter { $0.uid ?? 0 == superResolution.uid }
                    var stat = ""
                    switch superResolution.type {
                    case 3:
                        stat = "2倍超分"
                    case 6:
                        stat = "1倍超分（自研锐化）"
                    case 7:
                        stat = "1.33倍超分"
                    case 8:
                        stat = "1.5倍超分"
                    case 10:
                        stat = "CPU锐化"
                    case 11:
                        stat = "GPU锐化"
                    case 20:
                        stat = "超级画质"
                    default:
                        break
                    }
                    videoView[0].statsInfo?.updateSuperResolution(stat)
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
}


extension JoinChannelVideoMain: SettingActionDelegate {
    func updateAudioSettingForkey(_ key: ShowAudioSettingKey) {
        switch key {
        case .AINS(let state):
            self.setAINS(with: state)
        case .AEC(let isOn):
            self.setAIAECOn(isOn: isOn!)
        case .AEC_LENGTH(let length):
            if ShowAudioSettingKey.AEC(isOn: nil).boolValue == false {
                return self.showAlert(title: "Error", message: "please open AEC first")
            }
            self.setAIAEC(with: length)
        case .AEC_FILTER_TYPE(let type):
            if ShowAudioSettingKey.AEC(isOn: nil).boolValue == false {
                return self.showAlert(title: "Error", message: "please open AEC first")
            }
            self.setAIAEC(type: type)
        }
    }
    
    func updateSettingForkey(_ key: ShowSettingKey) {
        let isOn = key.boolValue
        let indexValue = key.intValue
        let sliderValue = key.floatValue
        
        switch key {
        case .lowlightEnhance:
            agoraKit.setLowlightEnhanceOptions(isOn, options: AgoraLowlightEnhanceOptions())
        case .colorEnhance:
            agoraKit.setColorEnhanceOptions(isOn, options: AgoraColorEnhanceOptions())
        case .videoDenoiser:
            agoraKit.setVideoDenoiserOptions(isOn, options: AgoraVideoDenoiserOptions())
        case .beauty:
            agoraKit.setBeautyEffectOptions(isOn, options: AgoraBeautyOptions())
        case .PVC:
            agoraKit.setParameters("{\"rtc.video.enable_pvc\":\(isOn)}")
        case .SR:
            let srType: SRType = indexValue == 0 ? .x1_33 : .x2
            setSuperResolutionOn(isOn, srType: srType)
        case .BFrame:
           break
        case .videoEncodeSize:
            let index = indexValue % dimensionsItems.count
            let dimensions = dimensionsItems[index]
            videoEncoderConfig.dimensions = dimensions
            agoraKit.setVideoEncoderConfiguration(videoEncoderConfig)
        case .videoBitRate:
            videoEncoderConfig.bitrate = Int(sliderValue)
            agoraKit.setVideoEncoderConfiguration(videoEncoderConfig)
        case .FPS:
            let index = indexValue % fpsItems.count
            videoEncoderConfig.frameRate = fpsItems[index]
            agoraKit.setVideoEncoderConfiguration(videoEncoderConfig)
            // 采集帧率
            captureConfig.frameRate = Int32(fpsItems[index].rawValue)
        case .H265:
            setH265On(isOn)
        case .earmonitoring:
            agoraKit.enable(inEarMonitoring: isOn)
        case .recordingSignalVolume:
            agoraKit.adjustRecordingSignalVolume(Int(sliderValue))
        case .musincVolume:
            agoraKit.adjustAudioMixingVolume(Int(sliderValue))
        case .audioBitRate:
            break
        case .captureVideoSize:
            let index = indexValue % captureDimensionsItems.count
            captureConfig.dimensions = captureDimensionsItems[index]
        }
    }

    func setSuperResolutionOn(_ isOn: Bool, srType:SRType = .none) {
        if !isOn {
            videos.forEach { v in
                v.statsInfo?.updateSuperResolution("")
            }
        }
        if srType == .none {
            agoraKit.setParameters("{\"rtc.video.enable_sr\":{\"enabled\":\(false), \"mode\": 2}}")
        } else {
            agoraKit.setParameters("{\"rtc.video.enable_sr\":{\"enabled\":\(false), \"mode\": 2}}")
            agoraKit.setParameters("{\"rtc.video.sr_type\":\(srType.rawValue)}")
            agoraKit.setParameters("{\"rtc.video.sr_max_wh\":\(921600)}")
            // enabled要放在srType之后 否则修改超分倍数可能不会立即生效
            agoraKit.setParameters("{\"rtc.video.enable_sr\":{\"enabled\":\(isOn), \"mode\": 2}}")
        }
    }
    
    /**
     * 开启/关闭 AI降噪
     * @param
     * @return 开启/关闭回声消除的结果
     */
    public func setAINS(with level: ShowAudioSettingKey.AINS_STATE) {
        switch level {
        case .high:
            agoraKit.setParameters("{\"che.audio.ains_mode\":2}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":10}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":10}")
            agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":0}")
            agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":8}")
            agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}")
        case .mid:
            agoraKit.setParameters("{\"che.audio.ains_mode\":2}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":80}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":50}")
            agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":5}")
            agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":30}")
            agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}")
        case .off:
            agoraKit.setParameters("{\"che.audio.ains_mode\":-1}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":80}")
            agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":50}")
            agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":5}")
            agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":30}")
            agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}")
        }
    }
    
    //AIAEC-AI回声消除
    public func setAIAECOn(isOn: Bool){
        //agora_ai_echo_cancellation
//        rtcKit.enableExtension(withVendor: "agora_ai_echo_cancellation", extension: "", enabled: true)
        if (isOn){
            agoraKit.setParameters("{\"che.audio.aiaec.working_mode\":1}");
        } else {
            agoraKit.setParameters("{\"che.audio.aiaec.working_mode\":0}");
        }
    }
    
    public func setAIAEC(with length: ShowAudioSettingKey.AEC_FILTER_LENGTH) {
        switch length {
        case .small:
            agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":48}")
        case .middle:
            agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":200}")
        case .long:
            agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":460}")
        }
    }
    
    public func setAIAEC(type: Int) {
        agoraKit.setParameters("{\"che.audio.aec.linear_filter_type\":\(type)}");
    }

}
