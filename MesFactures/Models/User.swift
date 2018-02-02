//
//  User.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc private dynamic var _identifier: String = ""
    @objc private dynamic var _username = ""
    @objc private dynamic var _email = ""
    @objc private dynamic var _password = ""
    
    var identifier: String {
        get {
            return _identifier
        }set {
            realm?.beginWrite()
            _identifier = newValue
            try? realm?.commitWrite()
        }
    }
    
    var username: String {
        get {
            return _username
        }set {
            realm?.beginWrite()
            _username = newValue
            try? realm?.commitWrite()
        }
    }
    
    var email: String {
        get {
            return _email
        }set {
            realm?.beginWrite()
            _email = newValue
            try? realm?.commitWrite()
        }
    }
    
    var password: String {
        get {
            return _password
        }set {
            realm?.beginWrite()
            _password = newValue
            try? realm?.commitWrite()
        }
    }
}
