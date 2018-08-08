//
//  UIImageView.swift
//  YoutubeCloneApp
//
//  Created by Sébastien on 21/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIButton {
    
    func loadImage(with urlString: String) {
        if let url = URL(string: urlString) {
            if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
                setImage(imageFromCache, for: .normal)
            } else {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error as Any)
                    }
                    
                    if let receivedData = data {
                        DispatchQueue.main.async {
                            let imageToCache = UIImage(data: receivedData)
                            self.setImage(imageToCache, for: .normal)
                            imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                        }
                    }
                }.resume()
            }
        }
    }
}
