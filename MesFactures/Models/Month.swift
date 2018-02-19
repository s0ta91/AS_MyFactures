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
    
    func addInvoice (_ description: String, _ amount: Double, _ categoryName: String? = nil, _ identifier: String? = nil) {
        let newInvoice = Invoice()
        newInvoice.identifier = identifier
        newInvoice.detailedDescription = description
        newInvoice.categoryName = categoryName
        newInvoice.amount = amount
        print(newInvoice)
        realm?.beginWrite()
        _invoiceList.append(newInvoice)
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
    
    func removeInvoice (invoice: Invoice) {
        realm?.beginWrite()
        realm?.delete(invoice)
        try? realm?.commitWrite()
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
