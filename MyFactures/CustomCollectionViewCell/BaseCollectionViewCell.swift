//
//  BaseCollectionViewCell.swift
//  YoutubeCloneApp
//
//  Created by Sébastien on 08/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
