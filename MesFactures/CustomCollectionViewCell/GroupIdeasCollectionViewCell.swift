//
//  GroupIdeasCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 08/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupIdeasCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_groupIdeaNameLabel: UILabel!
    
    func setTitle (_ groupIdeaTitle: String) {
        ui_groupIdeaNameLabel.text = groupIdeaTitle
    }
}
