//
//  AgoraMeetingCell.swift
//  SZHDemo
//
//  Created by jinggang on 2023/9/19.
//

import UIKit


class AgoraMeetingCell: UICollectionViewCell {
//    var audioOnly:Bool = false
//    var isHost:Bool = true
    private var _audioOnly:Bool = false
    private var _isHost:Bool = false
    
    var cellPopView:MeetingCellPop!
    @IBOutlet weak var backVideoView: UIView!
    
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var hostImage: UIImageView!
    
    @IBOutlet weak var audioBtn: UIButton!
    
    @IBOutlet weak var usernameL: UILabel!
    
    @IBOutlet weak var audioBtnConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.masksToBounds = true
        avatarImage.cornerRadius = 35
    }
    override func layoutSubviews() {
        contentView.bringSubviewToFront(topBtn)
        contentView.bringSubviewToFront(moreBtn)
        contentView.bringSubviewToFront(avatarImage)
        contentView.bringSubviewToFront(hostImage)
        contentView.bringSubviewToFront(audioBtn)
        contentView.bringSubviewToFront(usernameL)
    }

    var audioOnly: Bool {
        get {
            return _audioOnly
        }
        set {
            if (newValue == true) {//如果是纯音频 隐藏视频渲染视图
                avatarImage.isHidden = false
                backVideoView.isHidden = true
            }else {
                avatarImage.isHidden = true
                backVideoView.isHidden = false
            }
            _audioOnly = newValue
        }
    }
    
    var isHost: Bool {
        get {
            return _isHost
        }
        set {
            if (newValue == true) {//如果是主持人 显示标志
                hostImage.isHidden = false
                audioBtnConstraint.constant = 24
            }else {//如果不是主持人 隐藏标志
                hostImage.isHidden = true
                audioBtnConstraint.constant = 8
            }
            _isHost = newValue
        }
    }
    
    //点击置顶按钮
    @IBAction func topClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
    }
    
    
    //点击更多按钮
    @IBAction func moreClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(sender.isSelected){
            cellPopView = Bundle.main.loadNibNamed("MeetingCellPop", owner: nil, options: [:])?.first as? MeetingCellPop;
            cellPopView?.frame = CGRectMake(self.frame.width - 135 - 8, sender.frame.origin.y + 28, 135,170)
            cellPopView?.masksToBounds = true
            cellPopView?.cornerRadius = 10
            self.addSubview(cellPopView)
        }else {
            cellPopView.removeFromSuperview()
        }
    }
    
    
}
