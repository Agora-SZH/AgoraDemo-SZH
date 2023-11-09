//
//  MeetingSetWindowController.swift
//  APIExample
//
//  Created by hanxiaoqing on 2023/11/10.
//  Copyright © 2023 Agora Corp. All rights reserved.
//

import Cocoa

class MeetingSetWindowController: NSWindowController {
    
}


struct SettingMenuItem {
    var name: String
    var identifier: String
    var controller: String?
    var storyboard: String?
}

class SettingMenuController: NSViewController {

    var menus:[SettingMenuItem] = [
        SettingMenuItem(name: "会议设置", identifier: "headerCell"),

        SettingMenuItem(name: "音频设置", identifier: "menuCell", controller: "AudioSettingController", storyboard: "AudioSettingController"),
        SettingMenuItem(name: "视频设置", identifier: "menuCell", controller: "VideoSettingController", storyboard: "VideoSettingController"),

        
//        SettingMenuItem(name: "Join a channel (Video)".localized, identifier: "menuCell", controller: "JoinChannelVideo", storyboard: "JoinChannelVideo"),
    ]
    
    @IBOutlet weak var tableView:NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func loadSplitViewItem(item: SettingMenuItem) {
        var storyboardName = ""
        
        if let name = item.storyboard {
            storyboardName = name
        } else {
            storyboardName = "MeetingSetWindowController"
        }
        let board: NSStoryboard = NSStoryboard(name: storyboardName, bundle: nil)
        
        guard let splitViewController = self.parent as? NSSplitViewController,
            let controllerIdentifier = item.controller,
            let viewController = board.instantiateController(withIdentifier: controllerIdentifier) as? BaseView else { return }
        
        let splititem = NSSplitViewItem(viewController: viewController as NSViewController)
        
        let detailItem = splitViewController.splitViewItems[1]
        if let detailViewController = detailItem.viewController as? BaseView {
            detailViewController.viewWillBeRemovedFromSplitView()
        }
        splitViewController.removeSplitViewItem(detailItem)
        splitViewController.addSplitViewItem(splititem)
    }
}

extension SettingMenuController: NSTableViewDataSource, NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = menus[row]
        return item.identifier == "menuCell" ? 32 : 22
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let item = menus[row]
        return item.identifier != "headerCell"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = menus[row]
        // Get an existing cell with the MyView identifier if it exists
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: item.identifier), owner: self) as? NSTableCellView

        view?.imageView?.image = nil
        view?.textField?.stringValue = item.name

        // Return the result
        return view;
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 && tableView.selectedRow < menus.count {
            loadSplitViewItem(item: menus[tableView.selectedRow])
        }
    }
}


