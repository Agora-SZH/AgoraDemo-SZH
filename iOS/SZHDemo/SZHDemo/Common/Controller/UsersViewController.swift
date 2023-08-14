//
//  UsersViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/10.
//

import UIKit

class UsersViewController: UIViewController {
    var userArray:Array<Int> = [1,2,3,4]
    @IBOutlet weak var userTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension UsersViewController:UITableViewDelegate {
    
}

extension UsersViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "userCell"
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell==nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: cellID)
        }
        cell.imageView?.image = UIImage.init(named: "用户")
        cell.textLabel?.text = String(userArray[indexPath.row])
        return cell
    }
}
