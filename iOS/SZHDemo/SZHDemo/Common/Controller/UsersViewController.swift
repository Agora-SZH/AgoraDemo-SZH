//
//  UsersViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/10.
//
import Foundation
import UIKit

class UsersViewController: UIViewController {
    var userArray:Array<Int> = []
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
        // 创建一个URL对象，指定后台接口的地址
        if let url = URL(string: "http://10.82.103.206:8080/GetUsers") {
            // 创建一个URLSession对象
            let session = URLSession.shared
            // 创建一个可变的URLRequest对象，设置HTTP方法为POST
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            // 创建要发送的数据（使用JSON格式）
            let parameters = ["":""]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("无法创建请求数据: \(error)")
                return
            }
            // 设置请求头部信息
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // 创建一个数据任务
            let task = session.dataTask(with: request) { (data, response, error) in
                // 检查请求是否失败
                if let error = error {
                    print("请求失败: \(error)")
                    return
                }
                // 检查响应是否存在
                guard let response = response as? HTTPURLResponse else {
                    print("无法获取响应")
                    return
                }
                // 检查状态码
                if response.statusCode == 200 {
                    // 解析响应数据
                    if let data = data {
                        // 处理响应数据
                        let responseString = String(data: data, encoding: .utf8)
                        print("响应数据: \(responseString ?? "")")
                    }
                } else {
                    print("请求失败，状态码: \(response.statusCode)")
                }
            }
            // 开始任务
            task.resume()
        } else {
            print("无效的URL")
        }
    }
}



extension UsersViewController:UITableViewDelegate {
    
}

extension UsersViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserViewCell = (tableView.dequeueReusableCell(withIdentifier: "UserViewCell", for: indexPath)) as! UserViewCell
        cell.iconImage?.image = UIImage.init(named: "userIcon")
        cell.nameL?.text = String(userArray[indexPath.row])
        return cell
    }
}
