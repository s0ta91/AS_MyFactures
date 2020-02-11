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
            invoicesRequest.sortDescriptors = [NSSortDescriptor(key: "detailedDescription", ascending: true)]
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
    
    
    // MARK: - PUBLIC
    func addInvoice(description: String, amount: Double, categoryObject: CategoryCD? = nil ,identifier: String?, documentType: String?, completion: ((InvoiceCD)->Void)? = nil) {
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
        completion?(newInvoice)
    }
    
    func update() {
        setTotalAmout()
        setTotalDocuments()
    }
    
    func setInvoiceList (for receivedCategory: CategoryCD, searchText: String = "") {
        _invoiceListToShow.removeAll(keepingCapacity: false)
//        var invoiceResults: [InvoiceCD]
        
        if receivedCategory.title == ALL_CATEGORY_TEXT && searchText != "" {
            _invoiceListToShow = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let detailDescription = invoice.detailedDescription else { return false }
                return detailDescription.contains(searchText)
            }
        }else if receivedCategory.title != ALL_CATEGORY_TEXT && searchText != "" {
            _invoiceListToShow = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let category = invoice.category else { return false }
                return receivedCategory == category
            }.filter({ (invoice) -> Bool in
                guard let detailDescription = invoice.detailedDescription else { return false }
                return detailDescription.contains(searchText)
            })
        }else if receivedCategory.title != ALL_CATEGORY_TEXT && searchText == "" {
            _invoiceListToShow = _cdInvoiceList.filter { (invoice) -> Bool in
                guard let category = invoice.category else { return false }
                return receivedCategory == category
            }
        }else {
            _invoiceListToShow = _cdInvoiceList
        }
        
//        invoiceResults.forEach { (invoice) in
//            let index = _invoiceListToShow.insertionIndex(of: invoice) { (invoice1, invoice2) -> Bool in
//                guard let title1 = invoice1.detailedDescription,
//                    let title2 = invoice2.detailedDescription else { return false }
//                return title1 < title2
//            }
//            _invoiceListToShow.insert(invoice, at: index)
//        }
        
        
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
    
    func getIndex(forInvoice theInvoice: InvoiceCD) -> Int? {
        return _cdInvoiceList.firstIndex { (invoice) -> Bool in
            invoice == theInvoice
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
        guard let invoiceToShowIndex = _invoiceListToShow.firstIndex(of: invoice) else { return }
        _cdInvoiceList.remove(at: invoiceIndex)
        _invoiceListToShow.remove(at: invoiceToShowIndex)
        manager.context.delete(invoice)
        manager.saveCoreDataContext()
        update()
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
        totalAmount = 0
        _cdInvoiceList.forEach { (invoice) in
            totalAmount += invoice.amount
        }
    }
    
    private func setTotalDocuments() {
        totalDocument = Int64(_cdInvoiceList.count)
    }
}
