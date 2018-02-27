//
//  GroupCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 06/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

protocol GroupCollectionViewCellDelegate: class {
    func showGroupActions(groupCell: GroupCollectionViewCell)
}

class GroupCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var ui_titleLabel: UILabel!
    @IBOutlet weak var ui_totalPriceLabel: UILabel!
    @IBOutlet weak var ui_totalDocumentsLabel: UILabel!
    
    //MARK: - Variables
    weak var delegate: GroupCollectionViewCellDelegate?
    
    //MARK: - public functions
    func setValues (_ _manager: Manager, _ group: Group) {
        let totalAmount = String(describing: group.getTotalGroupAmount())
        let totalDocument = String(group.getTotalDocument())
        ui_titleLabel.text = group.title
        ui_totalPriceLabel.text = totalAmount
        ui_totalDocumentsLabel.text = totalDocument
        
        _manager.convertToCurrencyNumber(forLabel: ui_totalPriceLabel)
    }
    
    //MARK: - Actions
    @IBAction func groupActions(_ sender: Any) {
        delegate?.showGroupActions(groupCell: self)
    }
}
