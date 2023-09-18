//
//  HomeViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/9/18.
//

import UIKit

class HomeViewController: ABaseViewController {
    
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var joinView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView.isUserInteractionEnabled = true
        createView.masksToBounds = true
        createView.cornerRadius = 18
        let tapCreateGesture = UITapGestureRecognizer(target: self, action: #selector(tapCreateGesture(gesture:)))
        createView.addGestureRecognizer(tapCreateGesture)
        
        joinView.isUserInteractionEnabled = true
        joinView.masksToBounds = true
        joinView.cornerRadius = 18
        let tapJoinGesture = UITapGestureRecognizer(target: self, action: #selector(tapJoinGesture(gesture:)))
        joinView.addGestureRecognizer(tapJoinGesture)
        
    }
    @objc func tapCreateGesture(gesture: UITapGestureRecognizer) {
        var createMeetingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateMeetingVC") as! CreateMeetingVC
        createMeetingVC.title = "发起会议"
        self.navigationController?.pushViewController(createMeetingVC, animated: true)
    }
    @objc func tapJoinGesture(gesture: UITapGestureRecognizer) {
        var joinMeetingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinMeetingVC") as! JoinMeetingVC
        joinMeetingVC.title = "加入会议"
        self.navigationController?.pushViewController(joinMeetingVC, animated: true)
    }
}
