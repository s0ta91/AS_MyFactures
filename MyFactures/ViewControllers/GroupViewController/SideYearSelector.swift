//
//  SideYearSelector.swift
//  MyFactures
//
//  Created by Sébastien Constant on 11/12/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SideYearSelector: UIViewController {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideView: UIView!
    
    @IBOutlet weak var sideYearSelectorConstraint: NSLayoutConstraint!
    var isSideYearSelectorOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.leftAnchor.constraint(equalTo: sideView.rightAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addConstraint(withFormat: "H:[v0(\(view.frame.width))]", views: mainView)
        NotificationCenter.default.addObserver(self, selector: #selector(showSideYearSelector), name: NSNotification.Name("showHideSideYearSelector"), object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func showSideYearSelector() {
        if isSideYearSelectorOpen {
            self.sideYearSelectorConstraint.constant = -250
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.sideYearSelectorConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        isSideYearSelectorOpen = !isSideYearSelectorOpen
    }
}
