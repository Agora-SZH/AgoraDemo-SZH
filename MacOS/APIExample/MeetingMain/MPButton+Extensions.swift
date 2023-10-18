//
//  MPButton+Extensions.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraUIKit

extension MPButton {

    static func newToggleButton(image: NSImage?, alternateImage: NSImage?, title: String, imagePosition: ImagePosition)  -> MPButton {
        let btn = MPButton()
        btn.setButtonType(.toggle)
        btn.image = image
        btn.alternateImage = alternateImage
        btn.imagePosition = imagePosition
        btn.imageScaling = .scaleProportionallyDown
        let att = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 10),
                                                                 .foregroundColor: NSColor.white])
        btn.attributedTitle = att
        let attributedColor = NSColor(red: 19/255.0, green: 139/255.0, blue: 214/255.0, alpha: 1.0)
        let alternateAtt = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 10),
                                                                 .foregroundColor: attributedColor])
        btn.attributedAlternateTitle = alternateAtt
        btn.state = .on
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
