//
//  Group.swift
//  MyFactures
//
//  Created by Sébastien Constant on 03/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class GroupCD: NSManagedObject {
    
    let manager = Manager.instance
    
    private var _cdInvoiceList: [InvoiceCD] {
        let groupPredicate = NSPredicate(format: "group == %@", self)
        let groupRequest: NSFetchRequest<InvoiceCD> = InvoiceCD.fetchRequest()
        groupRequest.predicate = groupPredicate
        do {
            return try Manager.instance.context.fetch(groupRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [InvoiceCD]()
        }
    }
    private var filteredInvoiceList = [InvoiceCD]()
    var _invoiceListToShow : [InvoiceCD] = []
    let ALL_CATEGORY_TEXT = NSLocalizedString("All categories", comment: "")
    
    // MARK: - PUBLIC
    func addInvoice(with month: MonthCD, _ description: String, _ amount: Double, _ categoryObject: CategoryCD? = nil ,_ identifier: String?, _ documentType: String?) {
        let newInvoice = InvoiceCD(context: manager.context)
        newInvoice.identifier = identifier
        newInvoice.month = month
        newInvoice.documentType = documentType
        newInvoice.detailedDescription = description
        newInvoice.category = categoryObject
        newInvoice.amount = amount
        
        manager.saveCoreDataContext()
        updateTotalPrice()
        updateTotalDocuments()
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
    
    func modifyInvoice (atIndex index: Int, withMonth month: MonthCD, _ description: String, _ amount: Double, _ categoryObject: CategoryCD? = nil, _ identifier: String?, _ documentType: String?) {
        let updatedInvoice = InvoiceCD(context: manager.context)
        updatedInvoice.identifier = identifier
        updatedInvoice.documentType = documentType
        updatedInvoice.detailedDescription = description
        updatedInvoice.category = categoryObject
        updatedInvoice.amount = amount
        
        manager.saveCoreDataContext()
        
        updateTotalPrice()
    }
    
    func removeInvoice (invoice: InvoiceCD) {
        guard let invoiceIndex = _cdInvoiceList.firstIndex(of: invoice) else { return }
        _invoiceListToShow.remove(at: invoiceIndex)
        updateTotalDocuments()
        updateTotalPrice()
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

    func getTotalGroupAmount() -> Double {
        var totalAmount: Double = 0
        _cdInvoiceList.forEach { (invoice) in
            totalAmount += invoice.amount
        }
        return totalAmount
    }
    
    func getTotalDocuments() -> Int64 {
        return Int64(_cdInvoiceList.count)
    }
    
    
    // MARK: - Private
    private func updateTotalPrice() {
        totalPrice = getTotalGroupAmount()
    }
    
    private func updateTotalDocuments() {
        totalDocuments = getTotalDocuments()
    }
}
