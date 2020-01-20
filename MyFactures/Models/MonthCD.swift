//
//  Month.swift
//  MyFactures
//
//  Created by Sébastien Constant on 06/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class MonthCD: NSManagedObject {
    
    let manager = Manager.instance
    private var _cdInvoiceList: [InvoiceCD] {
        get {
            let invoicesRequest: NSFetchRequest<InvoiceCD> = InvoiceCD.fetchRequest()
            let invoicesPredicate = NSPredicate(format: "month == %@", self)
            invoicesRequest.predicate = invoicesPredicate
            
            do {
                return try Manager.instance.context.fetch(invoicesRequest)
            } catch (let error) {
                print("Error fetching DB: \(error)")
                return [InvoiceCD]()
            }
        }
    }
    
    // MARK: - PUBLIC
    func update() {
        setTotalAmout()
        setTotalDocuments()
    }
    
    func getInvoicesCount() -> Int {
        return _cdInvoiceList.count
    }
    
    private func setTotalAmout() {
        _cdInvoiceList.forEach { (invoice) in
            totalAmount += invoice.amount
        }
    }
    
    private func setTotalDocuments() {
        totalDocument = Int64(_cdInvoiceList.count)
    }
}
