//
//  ApplicationData.swift
//  MesFactures
//
//  Created by Sébastien on 10/01/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class ApplicationData: Object {
    @objc private dynamic var _currentDate: Date = Date()
    
    var currentDate: Date {
        return _currentDate
    }
}
