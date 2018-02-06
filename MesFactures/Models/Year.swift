//
//  yearsList.swift
//  MesFactures
//
//  Created by Sébastien on 10/01/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Year: Object {
    @objc private dynamic var _year: Int = 0
    @objc private dynamic var _selected: Bool = false
    
    var year: Int {
        get {
            return _year
        }set {
            realm?.beginWrite()
            _year = newValue
            try? realm?.commitWrite()
        }
    }
    
    var selected: Bool {
        get {
            return _selected
        }set {
            realm?.beginWrite()
            _selected = newValue
            try? realm?.commitWrite()
        }
    }
}
