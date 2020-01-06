//
//  Month.swift
//  MyFactures
//
//  Created by Sébastien Constant on 06/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class Month: NSManagedObject {
    let manager = Manager.instance
    private var _cdInvoiceList: [Invoice] {
        let groupRequest: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        do {
            return try Manager.instance.context.fetch(groupRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [Invoice]()
        }
    }
    private var filteredInvoiceList = [Invoice]()
    var _invoiceListToShow : [Invoice] = []
    let ALL_CATEGORY_TEXT = NSLocalizedString("All categories", comment: "")
 
    // MARK: - PUBLIC
    func getTotalAmount () -> Double {
        var totalAmount: Double = 0
        _invoiceListToShow.forEach { (invoice) in
            totalAmount += invoice.amount
        }
        return totalAmount
    }
    
    func addInvoice(_ description: String, _ amount: Double, _ categoryObject: Category? = nil ,_ identifier: String?, _ documentType: String?) {
        let newInvoice = Invoice(context: manager.context)
        newInvoice.identifier = identifier
        newInvoice.documentType = documentType
        newInvoice.detailedDescription = description
        newInvoice.category = categoryObject
        newInvoice.amount = amount
        
        manager.saveCoreDataContext()
        setTotalAmount(amount, .add)
        setTotalDocument(.add)
    }
    
    
    
    // MARK: - PRIVATE
    private func setTotalAmount (_ amount: Double, _ type: action) {
        if type == .add {
            totalAmount += amount
        }else {
            totalAmount -= amount
            if totalAmount < 0 {
                totalAmount = 0
            }
        }
    }
    
    private func setTotalDocument (_ type: action) {
        if type == .add {
            totalDocument += 1
        }else {
            totalDocument -= 1
        }
    }
    
    
}
