//
//  GroupIdea.swift
//  MesFactures
//
//  Created by Sébastien on 08/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class GroupIdea: Object {
    @objc private dynamic var _title: String = ""
    
    var title: String {
        get {
            return _title
        }set {
            realm?.beginWrite()
            _title = newValue
            try? realm?.commitWrite()
        }
    }
}
