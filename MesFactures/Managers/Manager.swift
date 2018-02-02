//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

public class Manager {
    
    private var _realm: Realm
    
    init (withRealm realm: Realm) {
        _realm = realm
    }
    
    private func getNewIdentifier () -> UUID {
        return UUID()
    }
    
    func createNewUser (_ username: String, _ email: String, _ password: String) {
        let newUser = User()
        let identifier = getNewIdentifier()
        newUser.identifier = identifier.uuidString
        newUser.username = username
        newUser.email = email
        newUser.password = password
        try? _realm.write {
            _realm.add(newUser)
        }
    }
}
