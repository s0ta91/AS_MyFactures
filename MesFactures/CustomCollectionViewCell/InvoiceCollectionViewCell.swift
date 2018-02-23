//
//  InvoiceCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

protocol InvoiceCollectionViewCellDelegate: class {
    func delete(invoiceCell: InvoiceCollectionViewCell)
    func share(invoiceCell: InvoiceCollectionViewCell)
    func modify(invoiceCell: InvoiceCollectionViewCell)
}

class InvoiceCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var ui_amountLabel: UILabel!
    @IBOutlet weak var ui_categoryLabel: UILabel!
    @IBOutlet weak var ui_invoiceTitleLabel: UILabel!
    
    //MARK: - Global variables
    var _ptManager: Manager?
    weak var delegate: InvoiceCollectionViewCellDelegate?
    
    
    //MARK: - Functions
    //TODO: Create a function to set values for the cell
    func setValues (_ amount: String, _ categoryName: String?, _ invoiceTitle: String) {
        ui_amountLabel.text = amount
        ui_categoryLabel.text = categoryName
        ui_invoiceTitleLabel.text = invoiceTitle
        
        if let _manager = _ptManager {
            _manager.convertToCurrencyNumber(forLabel: ui_amountLabel)
        }
    }
    
    //MARK: - IBActions
    
    //TODO: Define actions for delete button here
    @IBAction func deleteInvoice(_ sender: UIButton) {
        delegate?.delete(invoiceCell: self)
    }
    
    //TODO: Define actions for share button here
    @IBAction func shareInvoice(_ sender: UIButton) {
        delegate?.share(invoiceCell: self)
    }
    
    @IBAction func modifyInvoice(_ sender: UIButton) {
        delegate?.modify(invoiceCell: self)
    }
}
