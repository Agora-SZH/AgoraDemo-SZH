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
        
//        let audioState = MPButton.newToggleButton(image: NSImage(named: "bar-speaker0"), alternateImage: NSImage(named: "bar-speaker1"), title: "音频", imagePosition: .imageAbove)
//        let vedioState = MPButton.newToggleButton(image: NSImage(named: "bar-camera0"), alternateImage: NSImage(named: "bar-camera1"), title: "视频", imagePosition: .imageAbove)
//        let share = MPButton.newNormalButton(image: NSImage(named: "bar_chat0"), title: "共享", imagePosition: .imageAbove)
//        let  record = MPButton.newNormalButton(image: NSImage(named: "camera-rotate"), title: "录制", imagePosition: .imageAbove)
//        let  chat = MPButton.newNormalButton(image: NSImage(named: "bar_more0"), title: "聊天", imagePosition: .imageAbove)
//        let  users = MPButton.newNormalButton(image: NSImage(named: "bar_user0"), title: "成员", imagePosition: .imageAbove)
        
        var agSettings = AgoraSettings()
      
        let agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: "05039ead7cf5415ca365cce36d61350a",
                rtcToken: ""
            ),
            style: .floating,
            agoraSettings: agSettings,
            delegate: self
        )

        let mainView = window?.contentView
        agoraView.fills(view: mainView!)

        agoraView.join(channel: "test", as: .broadcaster)

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

 
