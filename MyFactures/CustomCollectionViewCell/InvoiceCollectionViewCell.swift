//
//  InvoiceCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

protocol InvoiceCollectionViewCellDelegate: class {
    func showAvailableActions(invoiceCell: InvoiceCollectionViewCell, buttonPressed: UIButton)
    func showPdfDocument(invoiceCell: InvoiceCollectionViewCell)
}

class InvoiceCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var ui_amountLabel: UILabel!
    @IBOutlet weak var ui_categoryLabel: UILabel!
    @IBOutlet weak var ui_invoiceTitleLabel: UILabel!
    @IBOutlet weak var ui_invoiceDocumentThumbnail: UIButton!
    
    //MARK: - Global variables
    weak var delegate: InvoiceCollectionViewCellDelegate?
    
    override func prepareForReuse() {
//        ui_invoiceDocumentThumbnail.imageView?.image = UIImage(named: "missing_document")
        ui_invoiceDocumentThumbnail.setImage(UIImage(named: "missing_document"), for: .normal)
    }
    
    //MARK: - Functions
    //TODO: Set values for the cell
    func setValues (forInvoice invoice: InvoiceCD, fontSize: CGFloat) {
        if let invoiceIdentifier = invoice.identifier {
            let thumbnailUrl = SaveManager.getUrl(forIdentifier: invoiceIdentifier, documentType: .thumbnail)
            ui_invoiceDocumentThumbnail.loadImage(with: thumbnailUrl.absoluteString)
        }
        ui_invoiceDocumentThumbnail.layer.cornerRadius = 4
        
        ui_amountLabel.text = String(describing: invoice.amount)
        ui_categoryLabel.text = invoice.category?.title
        ui_invoiceTitleLabel.text = invoice.detailedDescription
        ui_amountLabel.convertToCurrencyNumber()
        setFontSize(with: fontSize)
    }
    
    func setFontSize (with fontSize: CGFloat) {
        ui_amountLabel.font = ui_amountLabel.font.withSize(fontSize)
        ui_categoryLabel.font = ui_categoryLabel.font.withSize(fontSize)
        ui_invoiceTitleLabel.font = ui_invoiceTitleLabel.font.withSize(fontSize)
    }
    
    //MARK: - IBActions
    @IBAction func showAvailableActionsForInvoice(_ sender: UIButton) {
        delegate?.showAvailableActions(invoiceCell: self, buttonPressed: sender)
    }
    
    @IBAction func showPdfButtonPressed(_ sender: UIButton) {
        delegate?.showPdfDocument(invoiceCell: self)
    }
}
