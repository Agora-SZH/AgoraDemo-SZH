//
//  MeetingTabBar.swift
//  APIExample
//
//  Created by hanxiaoqing on 2023/10/19.
//  Copyright © 2023 Agora Corp. All rights reserved.
//

import Cocoa

class MeetingTabBar: NSView, NibLoadable {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer?.backgroundColor = .black.copy(alpha: 0.4)
    }
    
    
}
