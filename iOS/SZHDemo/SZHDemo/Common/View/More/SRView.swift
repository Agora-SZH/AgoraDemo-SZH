//
//  SRView.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/7.
//

import UIKit

protocol SRDelegate:NSObjectProtocol {
    func backToMoreView()
    func srAction(index:Int)
}

class SRView: UIView {
    var delegate:SRDelegate!
    @IBOutlet weak var SRSegment: UISegmentedControl!
    
    @IBAction func backToMoreView(_ sender: UIButton) {
        if (delegate != nil) {
            delegate.backToMoreView()
        }
    }
    
    @IBAction func SRClick(_ sender: UISegmentedControl) {
        if (delegate != nil) {
            delegate.srAction(index: sender.selectedSegmentIndex)
        }
    }
}
