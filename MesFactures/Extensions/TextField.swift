//
//  TextField.swift
//  MyFactures
//
//  Created by Sébastien on 14/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPadding() {
        let padding = CGRect(x: 0, y: 0, width: 15, height: self.frame.height)
        let paddingView = UIView(frame: padding)
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRadius() {
        self.layer.cornerRadius = 5
    }
}
