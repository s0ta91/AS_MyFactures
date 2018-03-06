//
//  InvoiceCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

protocol InvoiceCollectionViewCellDelegate: class {
    func showAvailableActions(invoiceCell: InvoiceCollectionViewCell)
    func showPdfDocument(invoiceCell: InvoiceCollectionViewCell)
}

class InvoiceCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var ui_amountLabel: UILabel!
    @IBOutlet weak var ui_categoryLabel: UILabel!
    @IBOutlet weak var ui_invoiceTitleLabel: UILabel!
    @IBOutlet weak var ui_invoiceDocumentThumbnail: UIButton!
    
    //MARK: - Global variables
    var _ptManager: Manager?
    weak var delegate: InvoiceCollectionViewCellDelegate?
    
    
    //MARK: - Functions
    //TODO: Create a function to set values for the cell
    func setValues (forInvoice invoice: Invoice) {
        guard let _manager = _ptManager else {fatalError("passthrough _ptManager does not exists")}
        var imageToShow = UIImage(named: "missing_document")
        if let invoiceIdentifier = invoice.identifier,
            let invoiceDocumentExtension = invoice.documentType,
            let documentUrl = SaveManager.loadDocument(withIdentifier: invoiceIdentifier, andExtension: invoiceDocumentExtension) {
                switch invoiceDocumentExtension {
                    case "PDF":
                        imageToShow = _manager.drawPDFfromURL(url: documentUrl)
                    case "JPG":
                        imageToShow = _manager.getImageFromURL(url: documentUrl)
                    default:
                        imageToShow = UIImage(named: "missing_document")
                }
        }
        ui_invoiceDocumentThumbnail.setImage(imageToShow, for: .normal)
        ui_amountLabel.text = String(describing: invoice.amount)
        ui_categoryLabel.text = invoice.categoryObject?.title
        ui_invoiceTitleLabel.text = invoice.detailedDescription
        _manager.convertToCurrencyNumber(forLabel: ui_amountLabel)
    }
    
    //MARK: - IBActions
    @IBAction func showAvailableActionsForInvoice(_ sender: Any) {
        delegate?.showAvailableActions(invoiceCell: self)
    }
    
    @IBAction func showPdfButtonPressed(_ sender: UIButton) {
        delegate?.showPdfDocument(invoiceCell: self)
    }
}
