//
//  ABaseViewController.swift
//  SZHDemo
//
//  Created by jinggang on 2023/9/4.
//

import UIKit

class ABaseViewController: UIViewController {

    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = UIColor(hex: 0x323c47)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x030303)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(activityIndicator)
    }
    
    func show(_ text: String) {
        if Thread.current.isMainThread {
            showNoQueue(text: text)
            return
        }
        DispatchQueue.main.sync { [unowned self] in
            self.showNoQueue(text: text)
        }
    }
    
    private func showNoQueue(text: String) {
//        self.view.makeToast(text, position: )
        self.show(text)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func dismissLoading() {
        activityIndicator.stopAnimating()
    }

}
