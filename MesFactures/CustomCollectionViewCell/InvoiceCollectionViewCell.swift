//
//  InvoiceCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class InvoiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_amountLabel: UILabel!
    @IBOutlet weak var ui_categoryLabel: UILabel!
    @IBOutlet weak var ui_invoiceTitleLabel: UILabel!
    
    func setValues (_ amount: String, _ categoryName: String, _ invoiceTitle: String) {
        ui_amountLabel.text = amount
        ui_categoryLabel.text = categoryName
        ui_invoiceTitleLabel.text = invoiceTitle
    }
    
    @IBAction func modifyInvoice(_ sender: Any) {
    }
    
    @IBAction func deleteInvoice(_ sender: Any) {
    }
    
    @IBAction func shareInvoice(_ sender: Any) {
    }
    
}
