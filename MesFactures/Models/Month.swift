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
    
    func addInvoice (_ invoice: Invoice) {
        realm?.beginWrite()
        realm?.add(invoice)
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
}
