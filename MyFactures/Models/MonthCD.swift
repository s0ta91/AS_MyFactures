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
        set {}
    }
    var _invoiceListToShow = [InvoiceCD]()
    let ALL_CATEGORY_TEXT = NSLocalizedString("All categories", comment: "")
    
    func addInvoice(description: String, amount: Double, categoryObject: CategoryCD? = nil ,identifier: String?, documentType: String?) {
        let newInvoice = InvoiceCD(context: manager.context)
        newInvoice.identifier = identifier
        newInvoice.month = self
        newInvoice.documentType = documentType
        newInvoice.detailedDescription = description
        newInvoice.category = categoryObject
        newInvoice.amount = amount
        
        _cdInvoiceList.append(newInvoice)
        manager.saveCoreDataContext()
        update()
    }
    
    // MARK: - PUBLIC
    func update() {
        setTotalAmout()
        setTotalDocuments()
    }
    
    func getInvoicesCount() -> Int {
        return _cdInvoiceList.count
    }
    
    func setInvoiceList (for receivedCategory: CategoryCD, searchText: String = "") {
        _invoiceListToShow.removeAll(keepingCapacity: false)
        var invoiceResults: [InvoiceCD]
        
        if receivedCategory.title == ALL_CATEGORY_TEXT && searchText != "" {
            invoiceResults = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let detailDescription = invoice.detailedDescription else { return false }
                return detailDescription.contains(searchText)
            }
        }else if receivedCategory.title != ALL_CATEGORY_TEXT && searchText != "" {
            invoiceResults = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let category = invoice.category else { return false }
                return receivedCategory == category
            }.filter({ (invoice) -> Bool in
                guard let detailDescription = invoice.detailedDescription else { return false }
                return detailDescription.contains(searchText)
            })
        }else if receivedCategory.title != ALL_CATEGORY_TEXT && searchText == "" {
            invoiceResults = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let category = invoice.category else { return false }
                return receivedCategory == category
            }
        }else {
            invoiceResults = _cdInvoiceList
        }
        
        invoiceResults.forEach { (invoice) in
            _invoiceListToShow.append(invoice)
        }
    }
    
    func getInvoiceCount () -> Int {
        return _invoiceListToShow.count
    }
    
    func getInvoice (atIndex index: Int, _ isListFiltered: Bool = false) -> InvoiceCD? {
        if index >= 0 && index < getInvoiceCount() {
            return _invoiceListToShow[index]
        } else {
            return nil
        }
    }
    
    func modifyInvoice (atIndex index: Int, _ description: String, _ amount: Double, _ categoryObject: CategoryCD? = nil, _ identifier: String?, _ documentType: String?) {
        let updatedInvoice = InvoiceCD(context: manager.context)
        updatedInvoice.identifier = identifier
        updatedInvoice.documentType = documentType
        updatedInvoice.detailedDescription = description
        updatedInvoice.category = categoryObject
        updatedInvoice.amount = amount
        
        manager.saveCoreDataContext()
        
        update()
    }
    
    func removeInvoice (invoice: InvoiceCD) {
        guard let invoiceIndex = _cdInvoiceList.firstIndex(of: invoice) else { return }
        _invoiceListToShow.remove(at: invoiceIndex)
        update()
        manager.context.delete(invoice)
        manager.saveCoreDataContext()
    }
    
    func getTotalAmount () -> Double {
        var totalAmount: Double = 0
        _invoiceListToShow.forEach { (invoice) in
            totalAmount += invoice.amount
        }
        return totalAmount
    }
    
    
    //MARK: - PRIVATE
    private func setTotalAmout() {
        _cdInvoiceList.forEach { (invoice) in
            totalAmount += invoice.amount
        }
    }
    
    private func setTotalDocuments() {
        totalDocument = Int64(_cdInvoiceList.count)
    }
}
