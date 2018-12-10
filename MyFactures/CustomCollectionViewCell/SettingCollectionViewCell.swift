//
//  SettingCollectionViewCell.swift
//  YoutubeCloneApp
//
//  Created by Sébastien on 22/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SettingCollectionViewCell: BaseCollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : .white
            nameLabel.textColor = isHighlighted ? .white : .black
            iconImageView.tintColor = isHighlighted ? .white : UIColor.darkGray
        }
    }
    
    var _settings: Setting? {
        didSet {
            nameLabel.text = _settings?.name.rawValue
            iconImageView.image = UIImage(named: (_settings?.imageName)!)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.darkGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setupViews() {
        addSubview(iconImageView)
        addSubview(nameLabel)
        
        addConstraint(withFormat: "H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)
        addConstraint(withFormat: "V:|[v0]|", views: nameLabel)
        addConstraint(withFormat: "V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
