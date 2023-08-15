//
//  UserViewCell.swift
//  SZHDemo
//
//  Created by jinggang on 2023/8/15.
//

import UIKit

class UserViewCell: UITableViewCell {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImage.layer.masksToBounds = true
        iconImage.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
