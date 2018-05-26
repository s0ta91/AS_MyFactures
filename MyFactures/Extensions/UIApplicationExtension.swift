//
//  UIApplicationExtension.swift
//  MyFactures
//
//  Created by Sébastien on 26/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
