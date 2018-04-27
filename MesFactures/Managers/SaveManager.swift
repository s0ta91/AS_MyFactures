//
//  SaveManager.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import UIKit

class SaveManager {

    static fileprivate func getDocumentDirectory () -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to access document directory")
        }
    }

    static private func getNewIdentifier () -> UUID {
        return UUID()
    }

    static func saveDocument (document: Any?, description: String, categoryObject: Category?, amount: Double, currentMonth: Month? = nil, newMonth: Month, invoice: Invoice? = nil, modify: Bool? = false, documentAdded: Bool? = nil, documentType: String?) {
        var identifier: String? = nil
        guard let documentExtension = documentType else {return print("Unknown document extension)")}

        if document != nil {
            if modify == true && invoice != nil && invoice?.identifier != nil {
                identifier = invoice!.identifier
            } else {
                identifier = getNewIdentifier().uuidString
            }

            let filename = "\(identifier!).\(documentExtension)"
            let destinationDirectory = getDocumentDirectory().appendingPathComponent(documentExtension, isDirectory: true)
            let destinationURL = destinationDirectory.appendingPathComponent(filename, isDirectory: false)
            if !FileManager.default.fileExists(atPath: destinationDirectory.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(atPath: destinationDirectory.path, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    fatalError("Cannot create destination directory -> \(error.localizedDescription)")
                }
            }

            if let documentUrl = document as? URL {
                do {
                    try FileManager.default.copyItem(at: documentUrl, to: destinationURL)
                } catch {
                    fatalError("Connot create file -> \(error.localizedDescription)")
                }
            } else {
                if let image = document as? UIImage {
                    let JPGImage = UIImageJPEGRepresentation(image, 1.0)
                    let createFileIsSuccess = FileManager.default.createFile(atPath: destinationURL.path, contents: JPGImage, attributes: nil)
                    if !createFileIsSuccess {
                        print("An error occurs. The document has not been written to path : \(destinationURL.path)")
                    }

                }
            }
        } else {
            print("No document receive in parameter")
        }

        if modify == false {
            newMonth.addInvoice(description, amount, categoryObject, identifier, documentExtension)
        } else {
            if let invoiceToModify = invoice {
                if invoiceToModify.identifier != nil && documentAdded == true {
                    identifier = invoiceToModify.identifier
                }
                if let previousMonth = currentMonth,
                    let invoiceIndex = previousMonth.removeInvoice(invoice: invoiceToModify) {
                    if newMonth.month == previousMonth.month {
                        newMonth.modifyInvoice(atIndex: invoiceIndex, description, amount, categoryObject, identifier, documentExtension)
                    } else {
                        newMonth.addInvoice(description, amount, categoryObject, identifier, documentExtension)
                    }
                }
            }
        }
    }

    static func loadDocument (withIdentifier identifier: String, andExtension documentExtension: String) -> URL? {
        let documentURL: URL?
        let filePath = "\(identifier).\(documentExtension)"
        let documentDirectory = getDocumentDirectory().appendingPathComponent(documentExtension, isDirectory: true)
        if !FileManager.default.fileExists(atPath: documentDirectory.path) {
            fatalError("Directory not found at path \(documentDirectory)")
        }
        let Url = documentDirectory.appendingPathComponent(filePath)
        if FileManager.default.fileExists(atPath: Url.path) {
            documentURL = Url
        } else {
            fatalError("File unavailable at path \(Url)")
        }
        return documentURL
    }

    static func removeDocument (forIdentifier identifier: String, andExtension documentExtension: String) {
        let filename = "\(identifier).\(documentExtension)"
        let fileDirectory = getDocumentDirectory().appendingPathComponent(documentExtension, isDirectory: true)
        let fileUrl = fileDirectory.appendingPathComponent(filename, isDirectory: false)

        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            fatalError("Cannot remove file. It does not exists")
        }
    }
}
