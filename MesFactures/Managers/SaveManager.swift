//
//  SaveManager.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

class SaveManager {
    
    static fileprivate func getDocumentDirectory () -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        }else {
            fatalError("Unable to access document directory")
        }
    }
    
    static private func getNewIdentifier () -> UUID {
        return UUID()
    }
    
    static func saveDocument (documentURL fromUrl: URL?, description: String, categoryObject: Category?, amount: Double, currentMonth: Month? = nil, newMonth: Month, invoice: Invoice? = nil, modify: Bool? = false, documentAdded: Bool? = nil) {
        var identifier: String? = nil
        
        if let documentFromUrl = fromUrl {
            if modify == true && invoice != nil && invoice?.identifier != nil {
                identifier = invoice!.identifier
            }else {
                identifier = getNewIdentifier().uuidString
            }
            let filename = "\(identifier!).pdf"
            let destinationDirectory = getDocumentDirectory().appendingPathComponent("PDF", isDirectory: true)
            let destinationURL = destinationDirectory.appendingPathComponent(filename, isDirectory: false)
            if !FileManager.default.fileExists(atPath: destinationDirectory.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(atPath: destinationDirectory.path, withIntermediateDirectories: false, attributes: nil)
                }catch {
                    fatalError("Cannot create destination directory -> \(error.localizedDescription)")
                }
            }
            
            
            do {
                try FileManager.default.copyItem(at: documentFromUrl, to: destinationURL)
            }catch {
                fatalError("Connot create file -> \(error.localizedDescription)")
            }
        }
        
        if modify == false {
            newMonth.addInvoice(description, amount, categoryObject ,identifier)
        }else {
            if let invoiceToModify = invoice {
                if invoiceToModify.identifier != nil && documentAdded == true {
                    identifier = invoiceToModify.identifier
                }
                if let previousMonth = currentMonth,
                    let invoiceIndex = previousMonth.removeInvoice(invoice: invoiceToModify) {
                    if newMonth.month == previousMonth.month {
                        newMonth.modifyInvoice(atIndex: invoiceIndex, description, amount, categoryObject, identifier: identifier)
                    }else {
                        newMonth.addInvoice(description, amount, categoryObject ,identifier)
                    }
                }
            }
        }
    }
    
    static func removeDocument (forIdentifier identifier: String) {
        let filename = "\(identifier).pdf"
        let fileDirectory = getDocumentDirectory().appendingPathComponent("PDF", isDirectory: true)
        let fileUrl = fileDirectory.appendingPathComponent(filename, isDirectory: false)
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
        }catch {
            fatalError("Cannot remove file. It does not exists")
        }
    }
}
