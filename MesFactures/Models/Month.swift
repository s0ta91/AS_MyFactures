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
        return _invoiceList.count
    }
    
    func addInvoice (_ description: String, _ amount: Double, _ categoryObject: Category? = nil ,_ identifier: String? = nil) {
        let newInvoice = Invoice()
        newInvoice.identifier = identifier
        newInvoice.detailedDescription = description
        newInvoice.categoryObject = categoryObject
        newInvoice.amount = amount
        
        realm?.beginWrite()
        _invoiceList.append(newInvoice)
        try? realm?.commitWrite()
    }
    
    func modifyInvoice (atIndex index: Int, _ description: String, _ amount: Double, _ categoryObject: Category? = nil, identifier: String?) {
        let updatedInvoice = Invoice()
        updatedInvoice.detailedDescription = description
        updatedInvoice.amount = amount
        updatedInvoice.categoryObject = categoryObject
        updatedInvoice.identifier = identifier
        
        realm?.beginWrite()
        _invoiceList.insert(updatedInvoice, at: index)
        try? realm?.commitWrite()
    }
    
    func getInvoice (atIndex index: Int) -> Invoice? {
        let invoice: Invoice?
        if index >= 0 && index < getInvoiceCount() {
            invoice = _invoiceList[index]
        }else {
            invoice = nil
        }
        return invoice
    }
    
    func getInvoiceIndex (forInvoice invoice: Invoice) -> Int? {
        return _invoiceList.index(of: invoice)
    }
    
    func removeInvoice (invoice: Invoice) -> Int? {
        let invoiceIndex = getInvoiceIndex(forInvoice: invoice)
        realm?.beginWrite()
        realm?.delete(invoice)
        try? realm?.commitWrite()
        return invoiceIndex
    }
    
    func getTotalAmount (forMonthIndex monthIndex: Int) -> Double {
        var totalAmount: Double = 0
        for invoice in 0...getInvoiceCount() {
            if let invoice = getInvoice(atIndex: invoice) {
                totalAmount = totalAmount + invoice.amount
            }
        }
        return totalAmount
    }
}
