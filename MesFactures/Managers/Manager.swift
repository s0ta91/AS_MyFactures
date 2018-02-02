//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Manager {
    
    private var _realm: Realm
    private let _userLists : Results<User>
    
    init (withRealm realm: Realm) {
        _realm = realm
        _userLists = _realm.objects(User.self)
    }
    
    private func getNewIdentifier () -> UUID {
        return UUID()
    }
    
    func createNewUser (_ password: String) {
        let newUser = User()
        let identifier = getNewIdentifier()
        newUser.identifier = identifier.uuidString
        newUser.password = password
        try? _realm.write {
            _realm.add(newUser)
        }
    }
    
    func getUserCount () -> Int{
        return _userLists.count
    }
}
