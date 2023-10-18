//
//  MeetingBeginWindowController.swift
//  APIExample
//
//  Created by hanxiaoqing on 2023/10/8.
//  Copyright © 2023 Agora Corp. All rights reserved.
//

import Cocoa

protocol MeetingBeginDelegate: NSObject {
    func didCreateMeeting()
    func didJoinMetting()
}


class MeetingBeginWindowController: NSWindowController {
    
    weak var delegate: MeetingBeginDelegate?

    override var windowNibName: NSNib.Name! {
        return NSNib.Name("MeetingBeginWindowController")
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
    }
    
    @IBAction func createMeeting(_ sender: NSButton) {
        delegate?.didCreateMeeting()
        close()
    }
    
    @IBAction func joinMetting(_ sender: NSButton) {
        delegate?.didJoinMetting()
        close()
    }
}
