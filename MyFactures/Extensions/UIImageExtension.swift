//
//  UIImageExtension.swift
//  MyFactures
//
//  Created by Sébastien Constant on 09/09/2019.
//  Copyright © 2019 Sébastien Constant. All rights reserved.
//

import UIKit

extension UIImage {
    
    func imageWithSize(scaledToSize newSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
