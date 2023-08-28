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
        //调用后台接口 GetUsers 获取user表中所有用户
        getUsers()
    }
    
    
    func getUsers() {
        // 发送 POST 请求
        let httpRequest = HTTPRequest()
        let url = URL(string: "http://10.82.103.206:8080/GetUsers")!
        // 发送 POST 请求
        let parameters = ["":""]
        httpRequest.sendPostRequest(url: url, parameters: parameters) { (data, error) in
            if let error = error {
                // 处理请求错误
                print("POST 请求发生错误：\(error)")
            } else if let data = data {
                // 处理返回的数据
                self.userArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Any>
                    self.userTable.reloadData()
                print("POST 请求收到数据：\(self.userArray ?? [])")
            }
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
        if let dictionary = self.userArray[indexPath.row] as? [String: Any], let value = dictionary["name"] {
            // 使用获取到的值进行操作
            cell.nameL?.text = value as? String
        }
        return cell
    }
}
