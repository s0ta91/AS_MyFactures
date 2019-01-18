//
//  AboutViewController.swift
//  MesFactures
//
//  Created by Sébastien on 16/04/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var ui_appVersionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_appVersionNumberLabel.text = "MyFactures \(Settings().APP_VERSION_NUMBER)"
    }
}
