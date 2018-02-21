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
    
    static func saveDocument (documentURL fromUrl: URL? = nil, description: String, categoryObject: Category?, amount: Double, month: Month) {
        let identifier = getNewIdentifier()
        let filename = "\(identifier).pdf"
        let destinationDirectory = getDocumentDirectory().appendingPathComponent("PDF", isDirectory: true)
        let destinationURL = destinationDirectory.appendingPathComponent(filename, isDirectory: false)
        if !FileManager.default.fileExists(atPath: destinationDirectory.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: destinationDirectory.path, withIntermediateDirectories: false, attributes: nil)
            }catch {
                fatalError("Cannot create destination directory -> \(error.localizedDescription)")
            }
        }
        
        if let documentFromUrl = fromUrl {
            do {
                try FileManager.default.copyItem(at: documentFromUrl, to: destinationURL)
            }catch {
                fatalError("Connot create file -> \(error.localizedDescription)")
            }
        }
        month.addInvoice(description, amount, categoryObject ,identifier.uuidString)
    }
}
