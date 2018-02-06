//
//  GroupCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 06/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_titleLabel: UILabel!
    @IBOutlet weak var ui_totalPriceLabel: UILabel!
    @IBOutlet weak var ui_totalDocumentsLabel: UILabel!
    
    func setValues (_ _manager: Manager, _ group: Group) {
        
        ui_titleLabel.text = group.title
        ui_totalPriceLabel.text = "\(group.totalPrice)"
        ui_totalDocumentsLabel.text = "\(group.totalDocuments)"
        
        _manager.convertToCurrencyNumber(forLabel: ui_totalPriceLabel)
    }
}
