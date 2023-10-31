//
//  MPButton+Extensions.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraUIKit

extension MPButton {
    
    func configToggleButton(title: String) {
        let att = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 11),
                                                                 .foregroundColor: NSColor.white])
        self.attributedTitle = att
        let attributedColor = NSColor(red: 19/255.0, green: 139/255.0, blue: 214/255.0, alpha: 1.0)
        let alternateAtt = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 11),
                                                                 .foregroundColor: attributedColor])
        self.attributedAlternateTitle = alternateAtt
    }

    static func newToggleButton(image: NSImage?, alternateImage: NSImage?, title: String, imagePosition: ImagePosition)  -> MPButton {
        let btn = MPButton()
        btn.setButtonType(.toggle)
        btn.isBordered = false
        btn.contentTintColor = .clear
                
        btn.toolTip = "瞅啥瞅，快戳啊";

        btn.imageScaling = .scaleProportionallyUpOrDown
        btn.imagePosition = imagePosition
        btn.imageHugsTitle = true
        
        btn.image = image
        btn.alternateImage = alternateImage
        
        let att = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 8),
                                                                 .foregroundColor: NSColor.white])
        btn.attributedTitle = att
        
        let attributedColor = NSColor(red: 19/255.0, green: 139/255.0, blue: 214/255.0, alpha: 1.0)
        let alternateAtt = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 8),
                                                                 .foregroundColor: attributedColor])
        btn.attributedAlternateTitle = alternateAtt
        return btn
    }
    
    static func newNormalButton(image: NSImage?, title: String, imagePosition: ImagePosition)  -> MPButton {
        let btn = MPButton()
        btn.setButtonType(.pushOnPushOff)
        btn.image = image
        btn.imagePosition = imagePosition
        btn.imageScaling = .scaleProportionallyDown
        btn.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 10),
                                                                 .foregroundColor: NSColor.white])
        return btn
    }
}
