//
//  SideYearSelector.swift
//  MyFactures
//
//  Created by Sébastien Constant on 11/12/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SideYearSelector: UIViewController {
    
    @IBOutlet weak var sideYearSelectorConstraint: NSLayoutConstraint!
    var isSideYearSelectorOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSideYearSelector), name: NSNotification.Name("showSideYearSelector"), object: nil)
    }
    
    @objc func showSideYearSelector() {
        if isSideYearSelectorOpen {
            sideYearSelectorConstraint.constant = -226
        } else {
            sideYearSelectorConstraint.constant = 0
        }
        isSideYearSelectorOpen = !isSideYearSelectorOpen
    }
}
