//
//  CreateMeetingVC.swift
//  SZHDemo
//
//  Created by jinggang on 2023/9/18.
//

import UIKit

class CreateMeetingVC: ABaseViewController {
    @IBOutlet weak var createView: UIView!
    
    @IBOutlet weak var pwSwitch: UISwitch!
    @IBOutlet weak var layoutCon: NSLayoutConstraint!
    
    @IBOutlet weak var pwView: UIView!
    
    @IBOutlet weak var meetNameTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    
    override func viewDidLoad() {
//        getMeettingInfo()
    }
    
    //是否设置会议密码
    @IBAction func passWordEnable(_ sender: UISwitch) {
        layoutCon.constant = sender.isOn ? 80 : 10
        pwView.isHidden = sender.isOn ? false : true
    }
    
    //创建会议
    @IBAction func CreateMeetting(_ sender: UIButton) {
        let url = "http://127.0.0.1:8090/CreateMeeting"
        let params = ["meet_name": meetNameTF.text ?? "",
                      "create_userid": 0,
                      "host_userid": 0,
                      "meet_theme": "",
                      "password": pwTF.text ?? ""] as [String : Any]
        NetworkManager.shared.postRequest(urlString: url, params: params) { response in
            ToastView.show(text: "Create meetting success")
        } failure: { String in
            ToastView.show(text: "failure:\(String)")
        }
    }
    
    
    func getMeettingInfo() {
        let url = "http://127.0.0.1:8090/QueryMeeting"
        let par:[String : Any] = ["meet_name":"SZHSA"]
        NetworkManager.shared.postRequest(urlString: url, params: par) { response in
            let data = response["Msg"] as? [String: Any]
//            let meet_name = data?["meet_name"]
            let password = data?["password"]
//            let create_userid = data?["create_userid"]
//            let host_userid = data?["host_userid"]
//            let meet_theme = data?["meet_theme"]
//            ToastView.show(text: password as! String)
        } failure: { String in
            ToastView.show(text: "failure:\(String)")
        }
    }
}
