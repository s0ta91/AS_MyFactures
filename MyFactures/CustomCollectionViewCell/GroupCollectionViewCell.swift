//
//  GroupCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 06/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

protocol GroupCollectionViewCellDelegate: class {
    func showGroupActions(groupCell: GroupCollectionViewCell, buttonPressed: UIButton)
}

class GroupCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var ui_titleLabel: UILabel!
    @IBOutlet weak var ui_totalPriceLabel: UILabel!
    @IBOutlet weak var ui_totalDocumentsLabel: UILabel!
    
    //MARK: - Variables
    weak var delegate: GroupCollectionViewCellDelegate?
    
    //MARK: - public functions
    func setValues (_ group: GroupCD, fontSize: CGFloat) {
        let totalAmount = String(describing: group.getTotalGroupAmount())
        let totalDocument = String(group.getTotalDocument())
        ui_titleLabel.text = group.title
        ui_totalPriceLabel.text = totalAmount
        ui_totalDocumentsLabel.text = totalDocument
        ui_totalPriceLabel.convertToCurrencyNumber()
        setFontSize(with: fontSize)
    }
    
    func setFontSize (with fontSize: CGFloat) {
        ui_titleLabel.font = ui_titleLabel.font.withSize(fontSize)
        ui_totalPriceLabel.font = ui_totalPriceLabel.font.withSize(fontSize)
        ui_totalDocumentsLabel.font = ui_totalDocumentsLabel.font.withSize(fontSize)
    }
    
    //MARK: - Actions
    @IBAction func groupActions(_ sender: UIButton) {
        delegate?.showGroupActions(groupCell: self, buttonPressed: sender)
    }
}
