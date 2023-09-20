//
//  VirtualBgView.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/16.
//

import UIKit

protocol VirtualBgDelegate:NSObjectProtocol {
    func virtualBgWithSource(enable:Bool, source:String)
}

class VirtualBgView: UIView {
    //背景图片path
    var sourceTag:Int!
    
    var delegate:VirtualBgDelegate!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var backImage2: UIImageView!
    @IBOutlet weak var checkView2: UIView!
    @IBOutlet weak var backImage3: UIImageView!
    @IBOutlet weak var checkView3: UIView!
    @IBOutlet weak var backImage4: UIImageView!
    @IBOutlet weak var checkView4: UIView!
    
    @IBAction func doneBtnClick(_ sender: Any) {
        if delegate != nil {
            switch sourceTag {
            case 100:
                delegate.virtualBgWithSource(enable: false, source: "")
            case 200:
                let path:String = Bundle.main.path(forResource: "black", ofType: "jpg")!
                delegate.virtualBgWithSource(enable: true, source: path)
            case 300:
                let path:String = Bundle.main.path(forResource: "blue", ofType: "jpg")!
                delegate.virtualBgWithSource(enable: true, source: path)
            case 400:
                let path:String = Bundle.main.path(forResource: "yellow", ofType: "jpg")!
                delegate.virtualBgWithSource(enable: true, source: path)
            default:
                delegate.virtualBgWithSource(enable: false, source: "")
            }
        }
    }
    
    func addTapGes() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBackImageView(gesture:)))
        backImage.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapBackImageView(gesture:)))
        backImage2.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapBackImageView(gesture:)))
        backImage3.addGestureRecognizer(tapGesture3)
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(tapBackImageView(gesture:)))
        backImage4.addGestureRecognizer(tapGesture4)
    }
    
    @objc func tapBackImageView(gesture: UITapGestureRecognizer) {
        let tag:Int = gesture.view?.tag ?? 100
        sourceTag = tag
        switch tag {
        case 100:
            checkView.isHidden = false
            checkView2.isHidden = true
            checkView3.isHidden = true
            checkView4.isHidden = true
        case 200:
            checkView.isHidden = true
            checkView2.isHidden = false
            checkView3.isHidden = true
            checkView4.isHidden = true
        case 300:
            checkView.isHidden = true
            checkView2.isHidden = true
            checkView3.isHidden = false
            checkView4.isHidden = true
        case 400:
            checkView.isHidden = true
            checkView2.isHidden = true
            checkView3.isHidden = true
            checkView4.isHidden = false
        default:
            checkView.isHidden = false
            checkView2.isHidden = true
            checkView3.isHidden = true
            checkView4.isHidden = true
        }
    }
}
