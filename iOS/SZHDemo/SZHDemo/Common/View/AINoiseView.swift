//
//  AINoiseView.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/3.
//

import UIKit

protocol AINoiseDelegate:NSObjectProtocol {
    func back()
    func AINoiseChange(index:Int)
    func AIHuishengChange(index:Int)
    func WeiyingChange(index:Int)
    func LvboqiChange(index:Int)
}

class AINoiseView: UIView {
    @IBOutlet weak var jiangzao: UISegmentedControl!
    @IBOutlet weak var huisheng: UISegmentedControl!
    @IBOutlet weak var weiying: UISegmentedControl!
    @IBOutlet weak var lvboqi: UISegmentedControl!
    var delegate:AINoiseDelegate!
    
    @IBAction func backToMoreView(_ sender: UIButton) {
        self.delegate.back()
    }
    @IBAction func noiseChange(_ sender: UISegmentedControl) {
        self.delegate.AINoiseChange(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func huishengChange(_ sender: UISegmentedControl) {
        self.delegate.AIHuishengChange(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func weiyingChange(_ sender: UISegmentedControl) {
        self.delegate.WeiyingChange(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func lvboqiChange(_ sender: UISegmentedControl) {
        self.delegate.LvboqiChange(index: sender.selectedSegmentIndex)
    }
}
