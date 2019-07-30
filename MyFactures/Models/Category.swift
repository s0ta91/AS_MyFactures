//
//  Category.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc private dynamic var _title: String = ""
    @objc private dynamic var _selected = false
    
    var title: String {
        get {
            return _title
        }set {
            realm?.beginWrite()
            _title = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    var selected: Bool {
        get {
            return _selected
        }set {
            realm?.beginWrite()
            _selected = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }

}
