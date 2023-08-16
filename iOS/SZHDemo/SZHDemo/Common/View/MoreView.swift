//
//  MoreView.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/2.
//

import UIKit

struct AINoisePramaters {
    var jiangzao:Int
    var huisheng:Int
    var weiying:Int
    var lvboqi:Int
}

//代理
protocol MoreDelegate:NSObjectProtocol {
    func Hidden()
    func H265Gen(enable:Bool)
    func ColorGen(enable:Bool)
    func LightGen(enable:Bool)
    func VideoGen(enable:Bool)
    func LessBitrate(enable:Bool)
    func ResolutionChange(index:Int)
    func FramerateChange(index:Int)
    func AINosie(noiseParameter:AINoisePramaters)
    func SuperResolutionAction(index:Int)
    func VirtualBgWithSource(source:String)
}



class MoreView: UIView {
    var delegate:MoreDelegate!
    var nosieView:AINoiseView!
    var srView:SRView!
    var virtualView:VirtualBgView!
    //ui
    @IBOutlet weak var srBtn: UIButton!
    
    //3A相关参数
    var nosiePramaters:AINoisePramaters!
    var srPramaters:Int = 0
    //顶部按钮--点击隐藏
    @IBAction func Hidden(_ sender: UIButton) {
        self.delegate.Hidden()
    }
    
    //H265
    @IBAction func H265(_ sender: UISwitch) {
        self.delegate.H265Gen(enable: sender.isOn)
    }
    
    //色彩增强
    @IBAction func ColorGen(_ sender: UISwitch) {
        self.delegate.ColorGen(enable: sender.isOn)
    }
    
    //暗光增强
    @IBAction func LightGen(_ sender: UISwitch) {
        self.delegate.LightGen(enable: sender.isOn)
    }
    
    //视频增强
    @IBAction func VideoGen(_ sender: UISwitch) {
        self.delegate.VideoGen(enable: sender.isOn)
    }
    
    //码率节省
    @IBAction func LessBitrate(_ sender: UISwitch) {
        self.delegate.LessBitrate(enable: sender.isOn)
    }
    
    //调整视频分辨
    @IBAction func ResolutionChange(_ sender: UISegmentedControl) {
        self.delegate.ResolutionChange(index: sender.selectedSegmentIndex)
    }
    
    //调整视频帧率
    @IBAction func FramerateChange(_ sender: UISegmentedControl) {
        self.delegate.FramerateChange(index: sender.selectedSegmentIndex)
    }
    
    //AI降噪
    @IBAction func AINoise(_ sender: UIButton) {
        nosieView = Bundle.main.loadNibNamed("AINoiseView", owner: nil, options: [:])?.first as? AINoiseView;
        nosieView?.frame = CGRectMake(0, 0, self.frame.size.width,400)
        nosieView?.masksToBounds = true
        nosieView?.cornerRadius = 25
        nosieView?.delegate = self
        if (nosiePramaters != nil) {
            nosieView.jiangzao.selectedSegmentIndex = nosiePramaters.jiangzao
            nosieView.huisheng.selectedSegmentIndex = nosiePramaters.huisheng
            nosieView.weiying.selectedSegmentIndex = nosiePramaters.weiying
            nosieView.lvboqi.selectedSegmentIndex = nosiePramaters.lvboqi
        }else{
            nosiePramaters = AINoisePramaters(jiangzao: 0, huisheng: 0, weiying: 0, lvboqi: 0)
        }
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.nosieView?.frame = CGRectMake(0, self.frame.size.height - 400, self.frame.size.width, 400)
            self.addSubview(self.nosieView!)
            self.bringSubviewToFront(self.nosieView!)
        }
    }
    

    //超分
    @IBAction func SuperOnorOff(_ sender: UIButton) {
        srView = Bundle.main.loadNibNamed("SRView", owner: nil, options: [:])?.first as? SRView;
        srView?.frame = CGRectMake(0, 0, self.frame.size.width,105)
        srView?.masksToBounds = true
        srView?.cornerRadius = 25
        srView?.delegate = self
        srView.SRSegment.selectedSegmentIndex = srPramaters
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.frame.origin = CGPointMake(0, self.frame.origin.y+self.frame.size.height - 105)
            self.srView?.frame = CGRectMake(0, 0, self.frame.size.width, 105)
            self.addSubview(self.srView!)
            self.bringSubviewToFront(self.srView!)
        }
    }
    
    @IBAction func VirtualBackground(_ sender: UIButton) {
        virtualView = Bundle.main.loadNibNamed("VirtualBgView", owner: nil, options: [:])?.first as? VirtualBgView;
        virtualView?.frame = CGRectMake(0, 0, self.frame.size.width,210)
        virtualView?.masksToBounds = true
        virtualView?.cornerRadius = 25
        virtualView.delegate = self
        virtualView.addTapGes()
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.frame.origin = CGPointMake(0, self.frame.origin.y+self.frame.size.height - 210)
            self.virtualView?.frame = CGRectMake(0, 0, self.frame.size.width, 210)
            self.addSubview(self.virtualView!)
            self.bringSubviewToFront(self.virtualView!)
        }
    }
    
}

    

//3A页面代理方法
extension MoreView:AINoiseDelegate {
    func back() {
        nosieView.removeFromSuperview()
        self.delegate.AINosie(noiseParameter: nosiePramaters)
    }
    
    func AINoiseChange(index: Int) {
        print("ai noise change to index: \(index)")
        nosiePramaters.jiangzao = index
        self.delegate.AINosie(noiseParameter: nosiePramaters)
    }
    
    func AIHuishengChange(index: Int) {
        print("ai huisheng change to index: \(index)")
        nosiePramaters.huisheng = index
        self.delegate.AINosie(noiseParameter: nosiePramaters)
    }
    
    func WeiyingChange(index: Int) {
        print("weiying  change to index: \(index)")
        nosiePramaters.weiying = index
        self.delegate.AINosie(noiseParameter: nosiePramaters)
    }
    
    func LvboqiChange(index: Int) {
        print("lvboqi  change to index: \(index)")
        nosiePramaters.lvboqi = index
        self.delegate.AINosie(noiseParameter: nosiePramaters)
    }
}

//超分页面delegate
extension MoreView:SRDelegate {
    func backToMoreView() {
        var title:String = ""
        switch srPramaters {
        case 0:do {
            title = "关闭"
        }
        case 1:do {
            title = "超分x1.33"
        }
        case 2:do {
            title = "超分x2"
        }
        default:
            title = "关闭"
        }
        self.srBtn.setTitle(title, for: .normal)
        self.srView.removeFromSuperview()
        self.frame.origin = CGPointMake(0, self.frame.origin.y-self.frame.size.height + 105)
    }
    func srAction(index: Int) {
        srPramaters = index
        self.delegate.SuperResolutionAction(index: index)
    }
}

//虚拟背景页面代理方法
extension MoreView:VirtualBgDelegate {
    func virtualBgWithSource(source: String) {
        virtualView.removeFromSuperview()
        self.frame.origin = CGPointMake(0, self.frame.origin.y-self.frame.size.height + 210)
        self.delegate.VirtualBgWithSource(source: source)
    }
}
