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
    @objc private dynamic var _totalAmount: Double = 0
    @objc private dynamic var _totalDocument: Int = 0
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
    
    var totalAmount: Double {
        get {
            return _totalAmount
        }set {
            realm?.beginWrite()
            _totalAmount = newValue
            try? realm?.commitWrite()
        }
    }
    
    var totalDocument : Int {
        get {
            return _totalDocument
        }set {
            realm?.beginWrite()
            _totalDocument = newValue
            try? realm?.commitWrite()
        }
    }
    
    enum action {
        case add
        case remove
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
        
        setTotalAmount(amount, .add)
        setTotalDocument(.add)
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
        
        setTotalAmount(amount, .add)
        setTotalDocument(.add)
    }
    
    func removeInvoice (invoice: Invoice) -> Int? {
        let invoiceIndex = getInvoiceIndex(forInvoice: invoice)
        setTotalAmount(invoice.amount, .remove)
        setTotalDocument(.remove)
        realm?.beginWrite()
        realm?.delete(invoice)
        do {
            try realm?.commitWrite()
        }catch {
//            print("Invoice has not been deleted.")
//            print("Restoring it's totalAmount and TotalDocument values")
            setTotalAmount(invoice.amount, .add)
            setTotalDocument(.add)
        }
        return invoiceIndex
    }
    
    func removeFromInvoiceToShow (atIndex index: Int) {
        _invoiceListToShow.remove(at: index)
    }

    
    private func setTotalAmount (_ amount: Double, _ type: action) {
        if type == .add {
            totalAmount = totalAmount + amount
        }else {
            totalAmount = totalAmount - amount
            if totalAmount < 0 {
                totalAmount = 0
            }
        }
    }
    
    private func setTotalDocument (_ type: action) {
        if type == .add {
            totalDocument = totalDocument + 1
        }else {
            totalDocument = totalDocument - 1
        }
    }
    
    func getTotalAmount () -> Double {
        var totalAmount: Double = 0
        for invoiceIndex in 0...getInvoiceCount() {
            if let invoice = getInvoice(atIndex: invoiceIndex) {
                totalAmount = totalAmount + invoice.amount
            }
        }
        return totalAmount
    }
}
