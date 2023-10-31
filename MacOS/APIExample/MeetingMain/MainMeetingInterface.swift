//
//  MainMeetingInterface.swift
//  APIExample
//
//  Created by hanxiaoqing on 2023/10/10.
//  Copyright © 2023 Agora Corp. All rights reserved.
//

import Cocoa
import AgoraUIKit
import AgoraRtcKit


class MainMeetingInterface: NSWindowController {
    
    var agoraView: AgoraVideoViewer?
    
    @IBOutlet weak var topBar: NSView!
    @IBOutlet weak var topBarSwitchViewBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var strechButton: NSButton!
    @IBOutlet weak var switchViewBtn: NSButton!
    
    @IBOutlet weak var meetingName: NSTextField!
    @IBOutlet weak var meetingTime: NSTextField!
    @IBOutlet weak var netWorkStatusImg: NSImageView!
    @IBOutlet weak var invitePeople: NSButton!
    
    @IBOutlet weak var bottomBar: NSView!
    
    @IBOutlet weak var micButton: NSButton!
    @IBOutlet weak var cameraButton: NSButton!
    @IBOutlet weak var endMeeting: NSButton!
    
    
    override var windowNibName: NSNib.Name! {
        return NSNib.Name("MainMeetingInterface")
    }
    
    override init(window: NSWindow!) {
        super.init(window: window)
    }
    
    required init?(coder: (NSCoder?)) {
        super.init(coder: coder!)
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
    override func loadWindow() {
        super.loadWindow()
        window?.center()
        
        topBar.wantsLayer = true
        topBar.layer?.backgroundColor = .black.copy(alpha: 0.4)
        switchViewBtn.wantsLayer = true
        switchViewBtn.layer?.borderColor = NSColor.gray.cgColor
        switchViewBtn.layer?.borderWidth = 1.2
        
        bottomBar.wantsLayer = true
        bottomBar.layer?.backgroundColor = .black.copy(alpha: 0.4)
        
        micButton.configToggleButton(title: "音频")
        cameraButton.configToggleButton(title: "视频")
        endMeeting.wantsLayer = true
        endMeeting.layer?.borderColor = NSColor.red.cgColor
        endMeeting.layer?.borderWidth = 0.8
        

        let agSettings = AgoraSettings()
        let agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: "cc64ef10d45e48448b526af8814daeb3",
                rtcToken: ""
            ),
            style: .floating,
            agoraSettings: agSettings,
            delegate: self
        )

        let mainView = window?.contentView
//        agoraView.fills(view: mainView!)


//        agoraView.join(channel: "123", as: .broadcaster)

        self.agoraView = agoraView
    }
    
      var segmentControl: NSSegmentedControl?


      @objc func segmentedControlHit(segc: NSSegmentedControl) {
          let segmentedStyle = [
              AgoraVideoViewer.Style.floating,
              AgoraVideoViewer.Style.grid
          ][segc.indexOfSelectedItem]

          self.agoraView?.style = segmentedStyle
      }
    
    
    @IBAction func openNotifyView(_ sender: NSButton) {
        
    }
    
    @IBAction func switchViewAction(_ sender: NSButton) {
        if sender.state == .on {
            topBarSwitchViewBtnWidthConstraint?.isActive = false
            strechButton.isHidden = true
        } else {
            topBarSwitchViewBtnWidthConstraint?.isActive = true
            strechButton.isHidden = false
        }
    }
    
    @IBAction func strechSpeakerView(_ sender: NSButton) {
        
    }
    
    
    
    @IBAction func switchMicOnOff(_ sender: NSButton) {
        
        
    }
    
    @IBAction func switchVideoOnOff(_ sender: NSButton) {
        
    }
    
    @IBAction func shareScreen(_ sender: NSButton) {
        
    }
    
    @IBAction func recordRtc(_ sender: NSButton) {
        
    }
    
    @IBAction func chatWithOthers(_ sender: NSButton) {
        
    }
    
    @IBAction func roomMembers(_ sender: NSButton) {
        
    }
    
    
    @IBAction func endMeeting(_ sender: NSButton) {
        
    }
    
}


extension MainMeetingInterface {
    
    
    
}


extension MainMeetingInterface: AgoraVideoViewerDelegate {
    func joinedChannel(channel: String) {
        /*
        if self.segmentControl != nil {
            return
        }
        let newControl = NSSegmentedControl(
            labels: ["floating", "grid"], trackingMode: .selectOne, target: self,
            action: #selector(segmentedControlHit)
        )
        newControl.selectedSegment = self.agoraView?.style == .floating ? 0 : 1
        self.view.addSubview(newControl)
        newControl.translatesAutoresizingMaskIntoConstraints = false
        [
            newControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            newControl.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10)
        ].forEach { $0.isActive = true }
         */
    }
}

 
