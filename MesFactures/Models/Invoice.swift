//
//  File.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Invoice: Object {
    @objc private dynamic var _identifier: String?
    @objc private dynamic var _filename: String = ""
    @objc private dynamic var _categoryName: String = ""
    @objc private dynamic var _amount: Double = 0
    
    var identifier: String? {
        get {
            return _identifier
        }set {
            realm?.beginWrite()
            _identifier = newValue
            try? realm?.commitWrite()
        }
    }
    
    var filename: String {
        get {
            return _filename
        }set {
            realm?.beginWrite()
            _filename = newValue
            try? realm?.commitWrite()
        }
    }
    
    var categoryName: String {
        get {
            return _categoryName
        }set {
            realm?.beginWrite()
            _categoryName = newValue
            try? realm?.commitWrite()
        }
    }
    
    var amount: Double {
        get {
            return _amount
        }set {
            realm?.beginWrite()
            _amount = newValue
            try? realm?.commitWrite()
        }
    }
}
