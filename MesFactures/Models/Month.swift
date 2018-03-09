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
    var _invoiceListToShow : [Invoice] = []
    
    var month: String {
        get {
            return _month
        }set {
            realm?.beginWrite()
            _month = newValue
            try? realm?.commitWrite()
        }
    }

    func getInvoiceCount () -> Int {
        return _invoiceListToShow.count
    }
    
    func setInvoiceList (containing nameParts: String = "") -> Results<Invoice> {
        _invoiceListToShow.removeAll(keepingCapacity: false)
        var invoiceResults: Results<Invoice>
        if nameParts != "" {
            let invoiceIndexPredicate = NSPredicate(format: "_detailedDescription CONTAINS[cd] %@", nameParts)
            invoiceResults = _invoiceList.filter(invoiceIndexPredicate)
        }else {
            invoiceResults = _invoiceList.filter("TRUEPREDICATE")
        }
        for invoice in invoiceResults {
            _invoiceListToShow.append(invoice)
        }
        return invoiceResults
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
    
    func getInvoice (atIndex index: Int, _ isListFiltered: Bool = false) -> Invoice? {
        let invoice: Invoice?
        if index >= 0 && index < getInvoiceCount() {
            if isListFiltered == false {
                invoice = _invoiceList[index]
            }else {
                invoice = _invoiceListToShow[index]
            }
        }else {
            invoice = nil
        }
        return invoice
    }
    
    func getInvoiceListFilteredCount (forCategory category: Category) -> Int {
        var filteredInvoiceList: Results<Invoice>
        let invoicePredicate = NSPredicate(format: "_categoryobject == %@", category)
        filteredInvoiceList = _invoiceList.filter(invoicePredicate)
        return filteredInvoiceList.count
    }
    func getInvoiceFiltered (ForCategory category: Category, atIndex index: Int) -> Invoice? {
        var invoice: Invoice? = nil
        var filteredInvoiceList: Results<Invoice>
        let invoicePredicate = NSPredicate(format: "_categoryobject == %@", category)
        filteredInvoiceList = _invoiceList.filter(invoicePredicate)
        invoice = filteredInvoiceList[index]
        return invoice
    }
    
    
    func getInvoiceIndex (forInvoice invoice: Invoice) -> Int? {
        return _invoiceList.index(of: invoice)
    }
    
    func removeInvoice (invoice: Invoice) -> Int? {
        var invoiceIndex: Int?
        if let index = getInvoiceIndex(forInvoice: invoice) {
            invoiceIndex = index
            realm?.beginWrite()
            _invoiceList.remove(at: index)
            try? realm?.commitWrite()
        }
        return invoiceIndex
    }
    
    func getTotalAmount (forMonthIndex monthIndex: Int, withFilter: Bool, forCategory category: Category? = nil) -> Double {
        var totalAmount: Double = 0
        if withFilter == false {
            for invoiceIndex in 0...getInvoiceCount() {
                if let invoice = getInvoice(atIndex: invoiceIndex) {
                    totalAmount = totalAmount + invoice.amount
                }
            }
        }else {
            if let selectedCategory = category {
                let numberOfInvoice = getInvoiceListFilteredCount(forCategory: selectedCategory)
                for invoiceIndex in 0..<numberOfInvoice {
                    if let invoice = getInvoiceFiltered(ForCategory: selectedCategory, atIndex: invoiceIndex) {
                        totalAmount = totalAmount + invoice.amount
                    }
                }
            }
        }
        return totalAmount
    }
}
