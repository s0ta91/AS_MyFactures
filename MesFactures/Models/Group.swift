//
//  Group.swift
//  MesFactures
//
//  Created by Sébastien on 04/01/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {
    
    @objc private dynamic var _title = ""
    @objc private dynamic var _totalPrice = 0.0
    @objc private dynamic var _totalDocuments = 0
//    private var _subCategoryList = List<Subcategory>()
    
    var title: String {
        get {
            return _title
        }
        set {
            realm?.beginWrite()
            _title = newValue
            try? realm?.commitWrite()
        }
    }
    
    var totalPrice: Double {
        get {
            return _totalPrice
        }set {
            realm?.beginWrite()
            _totalPrice = newValue
            try? realm?.commitWrite()
        }
    }
    
    var totalDocuments: Int {
        get {
            return _totalDocuments
        }set {
            realm?.beginWrite()
            _totalDocuments = newValue
            try? realm?.commitWrite()
        }
    }
    
//    func getSubcategoryCount () -> Int {
//        return _subCategoryList.count
//    }
//    
//    func getSubcategory (atIndex index: Int) -> Subcategory? {
//        return _subCategoryList[index]
//    }
//    
//    func getSubcategoryIndex (forSubcategory subcategory: Subcategory) -> Int!{
//        return _subCategoryList.index(of: subcategory)
//    }
//    
//    func addSubcategory (Subcategory: Subcategory, atIndex index: Int? = nil) -> Bool {
//        if let indexToUse = index {
//            return insertSubcategory(Subcategory, at: indexToUse)
//        }else {
//            return appendSubcategory(Subcategory)
//        }
//    }
//    
//    private func insertSubcategory (_ Subcategory: Subcategory, at index: Int) -> Bool{
//        let result: Bool
//        if index >= 0 && index <= getSubcategoryCount() {
//            realm?.beginWrite()
//            _subCategoryList.insert(Subcategory, at: index)
//            try? realm?.commitWrite()
//            result = true
//        }else{
//            result = false
//        }
//        return result
//    }
//    
//    private func appendSubcategory (_ Subcategory: Subcategory) -> Bool {
//            realm?.beginWrite()
//            _subCategoryList.append(Subcategory)
//            try? realm?.commitWrite()
//            return true
//    }
//    
//    func moveSubcategory (from indexSource: Int, to indexDest: Int) {
//        realm?.beginWrite()
//        _subCategoryList.move(from: indexSource, to: indexDest)
//        try? realm?.commitWrite()
//    }
//    
//    func removeSubcategory (atIndex index: Int) -> Subcategory? {
//        let subcategoryToDelete = getSubcategory(atIndex: index)
//        realm?.beginWrite()
//        _subCategoryList.remove(at: index)
//        try? realm?.commitWrite()
//        return subcategoryToDelete
//    }
}
