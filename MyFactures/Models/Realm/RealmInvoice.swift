//
//  RealmInvoice.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class RealmInvoice: Object {
    @objc private dynamic var _identifier: String?
    @objc private dynamic var _documentType: String?
    @objc private dynamic var _detailedDescription: String = ""
    @objc private dynamic var _categoryobject: RealmCategory?
    @objc private dynamic var _amount: Double = 0
    
    var identifier: String? {
        get {
            return _identifier
        }set {
            realm?.beginWrite()
            _identifier = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    var documentType: String? {
        get {
            return _documentType
        }set {
            realm?.beginWrite()
            _documentType = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }

    var detailedDescription: String {
        get {
            return _detailedDescription
        }set {
            realm?.beginWrite()
            _detailedDescription = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    var categoryObject: RealmCategory? {
        get {
            return _categoryobject
        }set {
            realm?.beginWrite()
            _categoryobject = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    var amount: Double {
        get {
            return _amount
        }set {
            realm?.beginWrite()
            _amount = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
}
