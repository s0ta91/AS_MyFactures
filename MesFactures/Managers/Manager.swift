//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainAccess

class Manager {
    
    private var _realm: Realm
    private let _userLists : Results<User>
    
    init (withRealm realm: Realm) {
        _realm = realm
        _userLists = _realm.objects(User.self)
    }
    
    func savePassword (_ password: String) {
        DbManager().saveMasterPassword(password)
    }
    
    func hasMasterPassword () -> Bool{
        return DbManager().getMasterPassword() != nil
    }
}
