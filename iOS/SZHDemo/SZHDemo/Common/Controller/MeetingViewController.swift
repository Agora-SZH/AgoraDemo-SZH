//
//  MeetingViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/7/31.
//

import UIKit
import AGEVideoLayout
import AgoraRtcKit

struct SuperResolution: Codable {
    let uid: Int
    let type: Int
}

class MeetingViewController: ViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    var appid:String = ""
    var token:String = ""
    var channel:String = ""
    var userId:Int32 = 0
    var userArray:Array<Int> = []
    var localVideo:VideoView!
    var remoteVideo:VideoView!
    var moreView:MoreView? = nil
    var currentResolution:CGSize = CGSizeZero //当前分辨率
    var currentFramerate:AgoraVideoFrameRate = .fps15 //当前帧率
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var agoraKit: AgoraRtcEngineKit!
    var ges : UIGestureRecognizer!
    var isJoined: Bool = false
    var popViewHidden: Bool = false
    var timer:Timer?
    var h = 0
    var m = 0
    var s = 0
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var channelL: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    
    var nosie:AINoisePramaters!
    var sr:Int = 0
    private let cellIdentifier = "AgoraMeetingCell"
    var zoomedView:UIView? = nil
    var exitBtn:UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelL.text = channel
        self.timeStart()//启动通话计时
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "AgoraMeetingCell", bundle: nil), forCellWithReuseIdentifier:cellIdentifier)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 190, height: 240) //设置每个单元格的大小
        collectionView.collectionViewLayout = layout
        
        //配置RtcEngine
        let config = AgoraRtcEngineConfig()
        config.appId = appid
        config.areaCode = GlobalSettings.shared.area
        config.channelProfile = .liveBroadcasting
        config.eventDelegate = self
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraKit.setClientRole(.broadcaster)
        agoraKit.enableVideo()
        agoraKit.enableAudio()
        
        //设置本地视频采集、编码参数
        let capturerConfig = AgoraCameraCapturerConfiguration()
        capturerConfig.cameraDirection = .front
        agoraKit.setCameraCapturerConfiguration(capturerConfig)
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: CGSize(width: 540, height: 720),
                frameRate: .fps15,bitrate: AgoraVideoBitrateStandard,orientationMode: .adaptative, mirrorMode: .auto))
        currentResolution = CGSizeMake(540, 720)
        currentFramerate = .fps15
        //设置本地预览视图
        localVideo = Bundle.loadVideoView(type: .local, audioOnly: false)
        localVideo.isUserInteractionEnabled = true
        localVideo.frame = CGRectMake(0, 100, 150, 180)
        //TODO:
        localVideo.isHidden = true
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        //加入频道
        let option = AgoraRtcChannelMediaOptions()
        option.publishCameraTrack = true
        option.publishMicrophoneTrack = true
        option.clientRoleType = GlobalSettings.shared.getUserRole()
        let result = self.agoraKit.joinChannel(byToken: self.token, channelId: self.channel, uid: 0, mediaOptions: option)
        if result != 0 {
            self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
        }
    }
    //静音按钮点击事件
    @IBAction func Volume(_ sender: UIButton) {
    }
    //切换摄像头
    @IBAction func CameraSwitch(_ sender: UIButton) {
        agoraKit.switchCamera()
    }
    
    //message
    @IBAction func ShowMessage(_ sender: UIButton) {
        ToastView.show(text: "Please input message!")
    }
    
    
    //mute 音频
    @IBAction func MuteAudio(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    //mute 视频
    @IBAction func MuteVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        // 获取可见的单元格
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems

        // 根据索引路径排序可见单元格
        let sortedIndexPaths = visibleIndexPaths.sorted { $0.item < $1.item }

        // 遍历排序后的索引路径，获取可见单元格
        for indexPath in sortedIndexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) {
                // 在这里使用可见单元格（cell）
                if indexPath.row == 0 {
                    let meettingCell = cell as! AgoraMeetingCell
                    meettingCell.audioOnly = sender.isSelected
                }
            }
        }
        
    }
    
    //当前频道所有用户
    @IBAction func AllUsers(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
    }
  
    //更多操作
    @IBAction func MoreOperation(_ sender: UIButton) {
        if (moreView == nil) {
            moreView = Bundle.main.loadNibNamed("MoreView", owner: nil, options: [:])?.first as? MoreView;
            moreView?.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,400)
            moreView?.masksToBounds = true
            moreView?.cornerRadius = 25
            moreView?.delegate = self
            //初始化参数
            moreView?.nosiePramaters = nosie
            moreView?.srPramaters = sr
            UIView .animate(withDuration: 0.3, delay: 0) {
                self.moreView?.frame = CGRectMake(0, self.view.frame.size.height - 400, self.view.frame.size.width, 400)
                self.view.addSubview(self.moreView!)
                self.view.bringSubviewToFront(self.moreView!)
                
            }
        }else {
            moreView?.frame = CGRectMake(0, self.view.frame.size.height-400, (moreView?.frame.size.width)!, (moreView?.frame.size.height)!)
        }
    }
    
    //退出频道
    @IBAction func Leave(_ sender: Any) {
        agoraKit.disableAudio()
        agoraKit.disableVideo()
        if isJoined {
            agoraKit.stopPreview()
            agoraKit.leaveChannel { (stats) -> Void in
                LogUtils.log(message: "left channel, duration: \(stats.duration)", level: .info)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //UICollectionCellDatasource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! AgoraMeetingCell
        
        //默认本地用户预览放在第一个cell的位置
        if indexPath.row == 0 {
            let localVideoCanvas = AgoraRtcVideoCanvas()
            localVideoCanvas.uid = UInt(userArray[0])
            localVideoCanvas.view = cell.backVideoView
            localVideoCanvas.renderMode = .hidden
            cell.usernameL.text = "\(localVideoCanvas.uid)"
            cell.topBtn.isSelected = true
            cell.isHost = true
            cell.audioOnly = false
            agoraKit.setupLocalVideo(localVideoCanvas)
            agoraKit.startPreview()
        }else {
            let remoteVideoCanvas = AgoraRtcVideoCanvas()
            remoteVideoCanvas.view = cell.backVideoView
            remoteVideoCanvas.uid = UInt(userArray[indexPath.row])
            remoteVideoCanvas.renderMode = .hidden
            cell.usernameL.text = "\(remoteVideoCanvas.uid)"
            cell.isHost = false
            cell.audioOnly = false
            agoraKit.setupRemoteVideo(remoteVideoCanvas)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select item at index \(indexPath.row)")
        //点击用户视图 进入演讲者模式
        // 获取选中的单元格
        guard let selectedCell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        // 获取选中单元格的位置信息
        let cellFrame = selectedCell.convert(selectedCell.bounds, to: collectionView.superview)
        // 创建一个放大后的视图
        zoomedView = UIView(frame: cellFrame)
        // 添加动画效果将其放大到全屏
        UIView.animate(withDuration: 0.3) {
            self.zoomedView?.frame = self.view.bounds
        }
        let remoteVideoCanvas = AgoraRtcVideoCanvas()
        remoteVideoCanvas.view = zoomedView
        remoteVideoCanvas.uid = UInt(userArray[indexPath.row])
        remoteVideoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(remoteVideoCanvas)
        // 将放大后的视图添加到视图层级中
        backView.addSubview(zoomedView!)
        
        exitBtn = UIButton(frame: CGRect(x: 100, y: 50, width: 30, height: 30))
        let backgroundImage = UIImage(named: "应用管理")
        exitBtn.setBackgroundImage(backgroundImage, for: .normal)
        
        exitBtn.addTarget(self, action: #selector(exitFullScreen), for: .touchUpInside)
        backView.addSubview(exitBtn)
    }
    //退出演讲者模式
    @objc func exitFullScreen() {
        zoomedView?.removeFromSuperview()
        collectionView.reloadData()
        exitBtn.removeFromSuperview()
    }
    //timer
    func timeStart() {
        if !(timer != nil) {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerIntervalx), userInfo: nil, repeats: true)
            }
    }
    @objc func timerIntervalx() {
            s+=1;
        if s==60 {
            m+=1
            s=0
        }
        if m==60 {
            h+=1
            m=0
        }
        var second :String = "00"
        var min :String = "00"
        var hour :String = "00"
        s > 9 ? (second = "\(s)") : (second = "0\(s)")
        m > 9 ? (min = "\(m)") : (min = "0\(m)")
        h > 9 ? (hour = "\(h)") : (hour = "0\(h)")
        timeL?.text = "\(hour):\(min):\(second)"
    }
    //自定义Alert
    func showAlert(title: String? = nil, message: String, textAlignment: NSTextAlignment = .center) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        if let messageLabel = alertController.view.value(forKeyPath: "_messageLabel") as? UILabel {
            messageLabel.textAlignment = textAlignment
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMeetingViewController(_ unwindSegue: UIStoryboardSegue) {
//        if let settingVC = unwindSegue.source as? SettingViewController {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUsersViewController"{
            let controller = segue.destination as! UsersViewController
            controller.userArray = self.userArray
        }
    }
}

/// agora rtc engine delegate events
extension MeetingViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        LogUtils.log(message: "warning: \(warningCode.description)", level: .warning)
    }
    

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        LogUtils.log(message: "error: \(errorCode)", level: .error)
        self.showAlert(title: "Error", message: "Error \(errorCode.description) occur")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.isJoined = true
        LogUtils.log(message: "Join \(channel) with uid \(uid) elapsed \(elapsed)ms", level: .info)
        //添加本地用户uid到user list
        userArray.append(Int(uid))
        print("joined")
        collectionView.reloadData()
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        LogUtils.log(message: "remote user join: \(uid) \(elapsed)ms", level: .info)
        //添加远端用户uid到user list
        userArray.append(Int(uid))
        collectionView.reloadData()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        LogUtils.log(message: "remote user left: \(uid) reason \(reason)", level: .info)
        //从到user list移除远端用户uid
        if userArray.contains(Int(uid)) {
         let index = userArray.firstIndex(of:Int(uid))
            userArray.remove(at: index!)
            collectionView.reloadData()
        }
//        self.remoteVideo.removeFromSuperview()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
//        localVideo.statsInfo?.updateChannelStats(stats)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStats stats: AgoraRtcLocalVideoStats, sourceType: AgoraVideoSourceType) {
//        localVideo.statsInfo?.updateLocalVideoStats(stats)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStats stats: AgoraRtcLocalAudioStats) {
//        localVideo.statsInfo?.updateLocalAudioStats(stats)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
//        remoteVideo.statsInfo?.updateVideoStats(stats)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
//        remoteVideo.statsInfo?.updateAudioStats(stats)
    }
        
    func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        if uid == userId {
//            if txQuality == .excellent || txQuality == .good || txQuality == .unknown {
//                stateImage.image = UIImage.init(named: "states-nice")
//            }
//            else if txQuality == .poor {
//                stateImage.image = UIImage.init(named: "states-poor")
//            }
//            else if txQuality == .bad || txQuality == .vBad || txQuality == .down || txQuality == .detecting || txQuality == .unsupported{
//                stateImage.image = UIImage.init(named: "states-bad")
//            }
        }
    }
}

//超分 MediaFilter 回调
extension MeetingViewController: AgoraMediaFilterEventDelegate{
    func onEvent(_ provider: String?, extension: String?, key: String?, value: String?) {
                if let srKey = key, srKey == "sr_type" {
                    if let jsonData = value?.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let superResolution = try decoder.decode(SuperResolution.self, from: jsonData)
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
//                            remoteVideo.statsInfo?.updateSuperResolution(stat)
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
    }
}


extension MeetingViewController: MoreDelegate {
    //隐藏页面
    func Hidden() {
        moreView?.frame = CGRectMake(0, self.view.frame.size.height, (moreView?.frame.size.width)!, (moreView?.frame.size.height)!)
    }
    
    //H265
    func H265Gen(enable: Bool) {
        print("H265: \(enable)")
        agoraKit.setParameters("{\"engine.video.enable_hw_encoder\":\(enable)}")
        agoraKit.setParameters("{\"engine.video.codec_type\":\"\(enable ? 3 : 2)\"}")
    }
    
    //色彩增强
    func ColorGen(enable: Bool) {
        print("ColorGen: \(enable)")
        let option = AgoraColorEnhanceOptions()
        option.strengthLevel = 1.0
        option.skinProtectLevel = 1.0
        agoraKit.setColorEnhanceOptions(enable, options: option)
    }
    //暗光增强
    func LightGen(enable: Bool) {
        print("LightGen: \(enable)")
        let option = AgoraLowlightEnhanceOptions()
        option.mode = .manual
        option.level = .fast
        agoraKit.setLowlightEnhanceOptions(enable, options: option)
    }
    
    //视频增强
    func VideoGen(enable: Bool) {
        print("VideoGen: \(enable)")
        let option = AgoraVideoDenoiserOptions()
        option.mode = .manual
        option.level = .fast
        agoraKit.setVideoDenoiserOptions(enable, options: option)
    }
    
    //节省码率
    func LessBitrate(enable: Bool) {
        print("LessBitrate: \(enable)")
        agoraKit.setParameters("{\"rtc.video.enable_pvc\":\(enable)}")
    }
    
    //调整视频分辨率
    func ResolutionChange(index: Int) {
        print("ResolutionChange to: \(index)")
        switch index {
        //480P
        case 0:do {
            currentResolution = CGSizeMake(480, 720)
        }
        //7200P
        case 1:do {
            currentResolution = CGSizeMake(720, 1080)
        }
        //1080P
        case 2:do {
            currentResolution = CGSizeMake(1080, 1920)
        }
        default:do {}
        }
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: currentResolution,
                frameRate: currentFramerate,bitrate: AgoraVideoBitrateStandard,orientationMode: .adaptative, mirrorMode: .auto))
        
    }
    
    //调整视频帧率
    func FramerateChange(index: Int) {
        print("FramerateChange to: \(index)")
        switch index {
        //15fps
        case 0:do {
            currentFramerate = .fps15
        }
        //30fps
        case 1:do {
            currentFramerate = .fps30
        }
        //60fps
        case 2:do {
            currentFramerate = .fps60
        }
        default:do {}
        }
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: currentResolution,
                frameRate: currentFramerate,bitrate: AgoraVideoBitrateStandard,orientationMode: .adaptative, mirrorMode: .auto))
    }
    
    
    //处理3A
    func AINosie(noiseParameter: AINoisePramaters) {
        nosie = noiseParameter
        print("jiangzao:\(noiseParameter.jiangzao)  \n huisheng:\(noiseParameter.huisheng) \n weiying:\(noiseParameter.weiying) \n lvboqi:\(noiseParameter.lvboqi)")
        /**AI降噪**/
        switch noiseParameter.jiangzao {
            case 0 : do {
                agoraKit.setParameters("{\"che.audio.ains_mode\":-1}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":80}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":50}");
                agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":5}");
                agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":30}");
                agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}");
                print("AI降噪：关闭")
            }
            case 1 : do {
                agoraKit.setParameters("{\"che.audio.ains_mode\":2}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":80}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":50}");
                agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":5}");
                agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":30}");
                agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}");
                print("AI降噪：中")
            }
            case 2 : do {
                agoraKit.setParameters("{\"che.audio.ains_mode\":2}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":10}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":10}");
                agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":0}");
                agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":8}");
                agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}");
                print("AI降噪：高")
            }
            default: do {
                agoraKit.setParameters("{\"che.audio.ains_mode\":-1}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerBound\":80}");
                agoraKit.setParameters("{\"che.audio.nsng.lowerMask\":50}");
                agoraKit.setParameters("{\"che.audio.nsng.statisticalbound\":5}");
                agoraKit.setParameters("{\"che.audio.nsng.finallowermask\":30}");
                agoraKit.setParameters("{\"che.audio.nsng.enhfactorstastical\":200}");
                print("AI降噪：关闭(默认)")
            }
        }
        /**回声消除**/
        switch noiseParameter.huisheng {
            case 0 : do {
                agoraKit.setParameters("{\"che.audio.aiaec.working_mode\":0}");
                print("回声消除：关闭")
            }
            case 1 : do {
                agoraKit.setParameters("{\"che.audio.aiaec.working_mode\":1}");
                print("回声消除：开启")
            }
            default: do {
                agoraKit.setParameters("{\"che.audio.aiaec.working_mode\":0}");
                print("回声消除：关闭(默认)")
            }
        }
        /**回声消除尾音长度**/
        switch noiseParameter.weiying {
            case 0 : do {
                agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":48}");
                print("回声消除尾音长度：小")
            }
            case 1 : do {
                agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":200}");
                print("回声消除尾音长度：中")
            }
            case 2 : do {
                agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":460}");
                print("回声消除尾音长度：大")
            }
            default: do {
                agoraKit.setParameters("{\"che.audio.aec.filter.length.ms\":48}");
                print("回声消除尾音长度：小(默认)")
            }
        }
        /**回声消除滤波器类型**/
        switch noiseParameter.huisheng {
            case 0 : do {
                agoraKit.setParameters("{\"che.audio.aec.linear_filter_type\":0}");
                print("回声消除：MMM")
            }
            case 1 : do {
                agoraKit.setParameters("{\"che.audio.aec.linear_filter_type\":1}");
                print("回声消除：SSS")
            }
            default: do {
                agoraKit.setParameters("{\"che.audio.aec.linear_filter_type\":0}");
                print("回声消除：MMM(默认)")
            }
        }
    }
    
    //超分辨率处理
    func SuperResolutionAction(index:Int) {
        sr = index
        var pameters:String = ""
        if (index == 0) {//关闭超分
            pameters = """
             {
               "rtc.video.sr_type": 7,
               "rtc.video.enable_sr": {
                 "enabled": \(false),
                 "mode": 2
               }
             }
            """
            agoraKit.setParameters(pameters)
//            remoteVideo.statsInfo?.updateSuperResolution("")
            print("关闭超分")
        }else if (index == 1) {//1.33倍超分
            pameters = """
             {
               "rtc.video.sr_type": 7,
               "rtc.video.enable_sr": {
                 "enabled": \(true),
                 "mode": 2
               }
             }
            """
            agoraKit.setParameters(pameters)
            print("1.33倍超分")
        } else if (index == 2) {//2倍超分
            pameters = """
             {
               "rtc.video.sr_type": 3,
               "rtc.video.enable_sr": {
                 "enabled": \(true),
                 "mode": 2
               }
             }
            """
            agoraKit.setParameters(pameters)
            print("2倍超分")
        }
    }
    
    //虚拟背景
    func VirtualBgWithSource(enable:Bool , source: String) {
        let back = AgoraVirtualBackgroundSource()
        back.backgroundSourceType = .img
        back.source = source
        agoraKit.enableVirtualBackground(enable, backData: back, segData: nil)
    }
}
