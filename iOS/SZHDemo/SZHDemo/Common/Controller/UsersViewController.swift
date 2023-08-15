//
//  UsersViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/10.
//

import UIKit

class UsersViewController: UIViewController {
    var userArray:Array<Int> = []
    @IBOutlet weak var userTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "UserViewCell", bundle: nil)
        userTable.register(cellNib, forCellReuseIdentifier: "UserViewCell")
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
