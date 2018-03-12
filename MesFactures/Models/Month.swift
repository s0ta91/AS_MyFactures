//
//  Month.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Month: Object {
    @objc private dynamic var _month: String = ""
    private var _invoiceList = List<Invoice>()
    private var filteredInvoiceList: Results<Invoice>?
    var _invoiceListToShow : [Invoice] = []
    let ALL_CATEGORY_TEXT = "Toutes les catégories"
    
    var month: String {
        get {
            return _month
        }set {
            realm?.beginWrite()
            _month = newValue
            try? realm?.commitWrite()
        }
    }

    func setInvoiceList (for category: Category, searchText: String = "") {
        _invoiceListToShow.removeAll(keepingCapacity: false)
        var invoiceResults: Results<Invoice>
        if category.title == ALL_CATEGORY_TEXT && searchText != "" {
            let invoiceIndexPredicate = NSPredicate(format: "_detailedDescription CONTAINS[cd] %@", searchText)
            invoiceResults = _invoiceList.filter(invoiceIndexPredicate)
        }else if category.title != ALL_CATEGORY_TEXT && searchText != "" {
            let categoryPredicate = NSPredicate(format: "_categoryobject == %@", category)
            let invoiceIndexPredicate = NSPredicate(format: "_detailedDescription CONTAINS[cd] %@", searchText)
            invoiceResults = _invoiceList.filter(categoryPredicate).filter(invoiceIndexPredicate)
        }else if category.title != ALL_CATEGORY_TEXT && searchText == "" {
            let categoryPredicate = NSPredicate(format: "_categoryobject == %@", category)
            invoiceResults = _invoiceList.filter(categoryPredicate)
        }else {
            invoiceResults = _invoiceList.filter("TRUEPREDICATE")
        }
        
        for invoice in invoiceResults {
            _invoiceListToShow.append(invoice)
        }
    }
    
    func getInvoiceCount () -> Int {
        return _invoiceListToShow.count
    }
    
    func getInvoice (atIndex index: Int, _ isListFiltered: Bool = false) -> Invoice? {
        let invoice: Invoice?
        if index >= 0 && index < getInvoiceCount() {
            invoice = _invoiceListToShow[index]
        }else {
            invoice = nil
        }
        return invoice
    }
    
    func getInvoiceIndex (forInvoice invoice: Invoice) -> Int? {
        return _invoiceList.index(of: invoice)
    }
    
    func addInvoice (_ description: String, _ amount: Double, _ categoryObject: Category? = nil ,_ identifier: String?, _ documentType: String?) {
        let newInvoice = Invoice()
        newInvoice.identifier = identifier
        newInvoice.documentType = documentType
        newInvoice.detailedDescription = description
        newInvoice.categoryObject = categoryObject
        newInvoice.amount = amount
        
        realm?.beginWrite()
        _invoiceList.append(newInvoice)
        try? realm?.commitWrite()
    }
    
    func modifyInvoice (atIndex index: Int, _ description: String, _ amount: Double, _ categoryObject: Category? = nil, _ identifier: String?, _ documentType: String?) {
        let updatedInvoice = Invoice()
        updatedInvoice.identifier = identifier
        updatedInvoice.documentType = documentType
        updatedInvoice.detailedDescription = description
        updatedInvoice.categoryObject = categoryObject
        updatedInvoice.amount = amount
        
        realm?.beginWrite()
        _invoiceList.insert(updatedInvoice, at: index)
        try? realm?.commitWrite()
    }
    
    func removeInvoice (invoice: Invoice) -> Int? {
        let invoiceIndex = getInvoiceIndex(forInvoice: invoice)
        realm?.beginWrite()
        realm?.delete(invoice)
        try? realm?.commitWrite()
        return invoiceIndex
    }
    
    func removeFromInvoiceToShow (atIndex index: Int) {
        _invoiceListToShow.remove(at: index)
    }
    
    func getTotalAmount (forMonthIndex monthIndex: Int) -> Double {
        var totalAmount: Double = 0
        for invoiceIndex in 0...getInvoiceCount() {
            if let invoice = getInvoice(atIndex: invoiceIndex) {
                totalAmount = totalAmount + invoice.amount
            }
        }
        return totalAmount
    }
}
