//
//  JoinMeetingVC.swift
//  SZHDemo
//
//  Created by jinggang on 2023/9/18.
//

import UIKit

class JoinMeetingVC: ABaseViewController {
    
    
    @IBAction func joinMeeting(_ sender: Any) {
        var homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController

        homeVC.appid = "aab8b8f5a8cd4469a63042fcfafe7063"
        homeVC.channel = "test"
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
}
