//
//  UsersViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/10.
//
import Foundation
import UIKit

class UsersViewController: UIViewController {
    var userArray:Array<Any>!
    @IBOutlet weak var userTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "UserViewCell", bundle: nil)
        userTable.register(cellNib, forCellReuseIdentifier: "UserViewCell")
        //TODO: 测试
        self.userArray.append("jinggang")
        self.userArray.append("zhangsan")
        self.userArray.append("lisi")
        //调用后台接口 GetUsers 获取user表中所有用户
        getUsers()
    }
    
    
    func getUsers() {
        let url = "http://127.0.0.1:8090/GetUserInfo"
        let par:[String : Any] = ["uid":888]
        NetworkManager.shared.postRequest(urlString: url, params: par) { _ in
            ToastView.show(text: "success")
        } failure: { String in
            ToastView.show(text: "failure:\(String)")
        }
    }
}



extension UsersViewController:UITableViewDelegate {
    
}

extension UsersViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserViewCell = (tableView.dequeueReusableCell(withIdentifier: "UserViewCell", for: indexPath)) as! UserViewCell
        cell.iconImage?.image = UIImage.init(named: "userIcon")
//        if let dictionary = self.userArray[indexPath.row] as? [String: Any], let value = dictionary["name"] {
//            // 使用获取到的值进行操作
            cell.nameL?.text = self.userArray[indexPath.row] as? String
//        }
        return cell
    }
}
