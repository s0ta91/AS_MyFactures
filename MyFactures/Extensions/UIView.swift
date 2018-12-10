//
//  UIView.swift
//  YoutubeCloneApp
//
//  Created by Sébastien on 07/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraint(withFormat format: String, views: UIView...) {
        var viewsDictionnary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionnary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionnary))
    }
}
