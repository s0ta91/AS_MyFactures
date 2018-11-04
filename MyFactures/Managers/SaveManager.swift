//
//  SaveManager.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import UIKit

enum DocumentType {
    case image
    case thumbnail
    case pdf
}

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
    
    static func saveDocument (document: Any?, description: String, categoryObject: Category?, amount: Double, currentMonth: Month? = nil, newMonth: Month, invoice: Invoice? = nil, modify: Bool? = false, documentAdded: Bool? = nil, documentType: String?) {
        var identifier: String? = nil
        guard let documentExtension = documentType else {return print("Unknown document extension)")}
        
        if document != nil {
            if modify == true && invoice != nil && invoice?.identifier != nil {
                identifier = invoice!.identifier
            }else {
                identifier = getNewIdentifier().uuidString
            }
            
            let destinationDirectory = getDocumentDirectory().appendingPathComponent(documentExtension, isDirectory: true)
            let thumbnailDirectory = getDocumentDirectory().appendingPathComponent("thumbnails", isDirectory: true)
            createDirectory(atPath: thumbnailDirectory.path)
            createDirectory(atPath: destinationDirectory.path)
            
            let filename = "\(identifier!).\(documentExtension)"
            let thumbnailFilename = "thumbnail_\(identifier!).JPG"
            
            let documentDestinationURL = destinationDirectory.appendingPathComponent(filename, isDirectory: false)
            let thumbnailDestinationURL = thumbnailDirectory.appendingPathComponent(thumbnailFilename, isDirectory: false)
            
            if let documentUrl = document as? URL {
                save(documentAtUrl: documentUrl, to: documentDestinationURL) {
                    saveThumbnail(withFilename: thumbnailFilename, fromUrl: documentUrl, to: thumbnailDestinationURL, withDocumentExtention: documentExtension)
                }
            }else {
                if let image = document as? UIImage {
                    save(image: image, atPath: documentDestinationURL.path) {
                        saveThumbnail(withFilename: thumbnailFilename, withImage: image, to: thumbnailDestinationURL, withDocumentExtention: documentExtension)
                    }
                }
            }
        } else {
            print("No document receive in parameter")
        }
        
        if modify == false {
            newMonth.addInvoice(description, amount, categoryObject ,identifier, documentExtension)
        }else {
            if let invoiceToModify = invoice {
                if invoiceToModify.identifier != nil && documentAdded == true {
                    identifier = invoiceToModify.identifier
                }
                if let previousMonth = currentMonth,
                    let invoiceIndex = previousMonth.removeInvoice(invoice: invoiceToModify) {
                    if newMonth.month == previousMonth.month {
                        newMonth.modifyInvoice(atIndex: invoiceIndex, description, amount, categoryObject, identifier, documentExtension)
                    }else {
                        newMonth.addInvoice(description, amount, categoryObject ,identifier, documentExtension)
                    }
                }
            }
        }
    }
    
    static func createDirectory(atPath destinationDirectory: String) {
        if !FileManager.default.fileExists(atPath: destinationDirectory, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: destinationDirectory, withIntermediateDirectories: false, attributes: nil)
            }catch {
                fatalError("Cannot create destination directory -> \(error.localizedDescription)")
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
    
    // TO DELETE
//    static func loadThumbnail(withIdentifier identifier: String) -> UIImage? {
//        let image: UIImage?
//
//        let thumbnailPath = "thumbnail_\(identifier).JPG"
//        let thumbnailDirectory = getDocumentDirectory().appendingPathComponent("thumbnails", isDirectory: true)
//        if !FileManager.default.fileExists(atPath: thumbnailDirectory.path) {
//            fatalError("Directory not found at path \(thumbnailDirectory)")
//        }
//        let thumbnailUrl = thumbnailDirectory.appendingPathComponent(thumbnailPath)
//        if FileManager.default.fileExists(atPath: thumbnailUrl.path) {
//            if let imageFromUrl = getImageFromURL(url: thumbnailUrl) {
//                image = imageFromUrl
//            } else {
//                image = nil
//            }
//            return image
//        } else {
//            fatalError("File unavailable at path \(thumbnailUrl)")
//        }
//    }
    
    static func getUrl(forIdentifier identifier: String, documentType: DocumentType) -> URL {
        
        let thumbnailPath = "\(documentType)_\(identifier).JPG"
        let thumbnailDirectory = getDocumentDirectory().appendingPathComponent("thumbnails", isDirectory: true)
        if !FileManager.default.fileExists(atPath: thumbnailDirectory.path) {
            fatalError("Directory not found at path \(thumbnailDirectory)")
        }
        return thumbnailDirectory.appendingPathComponent(thumbnailPath)
    }
    
    static func removeDocument (forIdentifier identifier: String, andExtension documentExtension: String) {
        let filename = "\(identifier).\(documentExtension)"
        let fileDirectory = getDocumentDirectory().appendingPathComponent(documentExtension, isDirectory: true)
        let fileUrl = fileDirectory.appendingPathComponent(filename, isDirectory: false)
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
        }catch {
            fatalError("Cannot remove file. It does not exists")
        }
    }

    static private func save(documentAtUrl url: URL, to destination: URL, completion: () -> Void) {
        do {
            try FileManager.default.copyItem(at: url, to: destination)
            completion()
        }catch {
            fatalError("Connot create file -> \(error.localizedDescription)")
        }
    }
    
    static private func save(image: UIImage, atPath imageDestinationPath: String, completion: () -> ()) {
        let JPGImage = image.jpegData(compressionQuality: 1.0)
        let createFileIsSuccess = FileManager.default.createFile(atPath: imageDestinationPath, contents: JPGImage, attributes: nil)
        if !createFileIsSuccess {
            print("Error. The document has not been written to path : \(imageDestinationPath)")
        }
    }
    
    static private func saveThumbnail(withFilename thumbnailFilename: String, fromUrl documentUrl: URL? = nil, withImage image: UIImage? = nil, to thumbnailDestinationURL: URL, withDocumentExtention documentExtension: String) {
        var data: Data?
        if let url = documentUrl {
            data = getThumbnailData(forUrl: url, documentExtension: documentExtension)
        }
        if let selectedImage = image {
            data = selectedImage.jpegData(compressionQuality: 1.0)
        }
        if let thumbnailData = data {
            let createFileIsSuccess = FileManager.default.createFile(atPath: thumbnailDestinationURL.path, contents: thumbnailData, attributes: nil)
            if !createFileIsSuccess {
                print("Error. The document has not been written to path : \(thumbnailDestinationURL.path)")
            }
        }
    }
    
    static private func drawPDFfromURL (forUrl url: URL) -> Data? {
        guard let document = CGPDFDocument(url as CFURL) else { print("error document")
            return nil }
        guard let page = document.page(at: 1) else { print("error page")
            return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        let imageData = img.jpegData(compressionQuality: 1.0)
        
        return imageData
    }
    
    static private func getImageData(forUrl url: URL) -> Data? {
        let imageData: Data?
        if let data = NSData(contentsOf: url),
            let image = UIImage(data: data as Data) {
            imageData = image.jpegData(compressionQuality: 1.0)
        }else {
            imageData = nil
        }
        return imageData
    }
    
    static private func getImageFromURL (url: URL) -> UIImage? {
        let image: UIImage?
        if let data = NSData(contentsOf: url) {
            image = UIImage(data: data as Data)
        }else {
            image = nil
        }
        return image
    }
    
    static private func getThumbnailData(forUrl url: URL, documentExtension: String) -> Data? {
        if documentExtension == "PDF" {
            return drawPDFfromURL(forUrl: url)
        } else {
            return getImageData(forUrl: url)
        }
    }
}
