//
//  DataManager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainAccess

class DbManager {
    private static let REALM_ENCRYPTION_KEY = "REALM_ENCRYPTION_KEY"
    private static let MASTER_PASSWORD = "MESFACTURES_MASTER_PASSWORD"
//    private static let ENCRYPT_FILE = true
    private static let ENCRYPT_FILE = false
    
    private var _database: Manager?
    private var _keychain: Keychain

    /** INIT functions **/
    init () {
        _keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.sebconstant.MyFactures")
    }
    
    
    /** PRIVATE functions **/
    private func loadRealmEncryptionKey () -> Data? {
        return _keychain[data: DbManager.REALM_ENCRYPTION_KEY]
    }
    
    private func generateRealmEncryptionKey () -> Data? {
        guard let generatedData = Data(countOfRandomData: 64) else { return nil }
        try! _keychain.set(generatedData, key: DbManager.REALM_ENCRYPTION_KEY)
        return generatedData
    }
    
    
    /** PUBLIC functions **/
    func getDb () -> Manager? {
        if DbManager.ENCRYPT_FILE == true {
            // try to load the key
            var possibleKey: Data?
            possibleKey = loadRealmEncryptionKey()
            
            //If no key, create a new key
            if possibleKey == nil {
                possibleKey = generateRealmEncryptionKey()
            }
            
            //realm config with the key
            if let realmEncryptionKey = possibleKey {
                let realmConf = Realm.Configuration(encryptionKey: realmEncryptionKey)
                let _realm = try! Realm(configuration: realmConf)
                _database = Manager(withRealm: _realm)
            }
        }else {
            let _realm = try! Realm()
            _database = Manager(withRealm: _realm)
        }
        return _database
    }
    
    func saveMasterPassword (_ password: String) {
        _keychain[DbManager.MASTER_PASSWORD] = password
    }
    func reInitMasterPassword () {
        _keychain[DbManager.MASTER_PASSWORD] = nil
    }
    func getMasterPassword () -> String? {
        return _keychain[DbManager.MASTER_PASSWORD]
    }
    
    
}
