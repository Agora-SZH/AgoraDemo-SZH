//
//  ViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/7/31.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var appidTF: UITextField!
    
    @IBOutlet weak var tokenTF: UITextField!
    
    @IBOutlet weak var channelTF: UITextField!
    
    @IBOutlet weak var userIdTF: UITextField!
    
    @IBOutlet weak var joinTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var domainName: UITextField!
    
    @IBOutlet weak var ipList: UITextField!
    
    @IBOutlet weak var joinBtn: UIButton!
    
    var moreHidden:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinBtn?.masksToBounds = true
        joinBtn?.cornerRadius = 15
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "join") {
            let controller = segue.destination as!MeetingViewController
            controller.appid = appidTF.text!
            controller.token = tokenTF.text!
            controller.channel = channelTF.text!
            controller.userId = 0
            NSLog("准备跳转")
        }
    }
    
    @IBAction func More(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if moreHidden {
            joinTopConstraint.constant = 150
            ipList.isHidden = false
            domainName.isHidden = false
            moreHidden = false
        }else {
            joinTopConstraint.constant = 80
            ipList.isHidden = true
            domainName.isHidden = true
            moreHidden = true
        }
    }
    @IBAction func unwindToViewController(_ unwindSegue: UIStoryboardSegue) {}

}



