//
//  AlertExtension.swift
//  MyFactures
//
//  Created by Sébastien on 17/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    class func message(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}
