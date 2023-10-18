//
//  CreateMettingWindowController.swift
//  APIExample
//
//  Created by hanxiaoqing on 2023/10/9.
//  Copyright © 2023 Agora Corp. All rights reserved.
//

import Cocoa

class CreateMettingWindowController: NSWindowController {
    
    @IBOutlet weak var mettingName: NSTextField!
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var passWord: NSTextField!
    
    @IBOutlet weak var beautySetting: NSButton!
    @IBOutlet weak var beginMeeting: NSButton!
    
    @IBOutlet weak var passWordView: NSView!
    
    let main = MainMeetingInterface()
    var isCreate: Bool = true
    
    override var windowNibName: NSNib.Name! {
        return NSNib.Name("CreateMettingWindowController")
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
    
    @IBAction func withPassWord(_ sender: NSButton) {
        passWord.isHidden = sender.state.rawValue == 0
    }
    
    @IBAction func openCamera(_ sender: NSButton) {
        
    }
    
    @IBAction func openMic(_ sender: NSButton) {
        
    }
    
    @IBAction func openBeauty(_ sender: NSButton) {
        beautySetting.isHidden = sender.state.rawValue == 0
    }
    
    
    @IBAction func settingBeauty(_ sender: NSButton) {
        
    }
    
    @IBAction func beginMeeting(_ sender: NSButton) {
        // service check if it has password
        
        // service save setting options
        
    
        main.loadWindow()
        window?.addChildWindow(main.window!, ordered: .above)
    }
    
    
    override func loadWindow() {
        super.loadWindow()
        window?.center()
        window?.title = isCreate ? "创建会议" : "加入会议"
        passWordView.isHidden = !isCreate
        mettingName.focusRingType = .none
        userName.focusRingType = .none
        passWord.focusRingType = .none
        beginMeeting.backgroundColor = .black
    }
}
