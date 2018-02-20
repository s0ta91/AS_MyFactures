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
    private var _groupList = List<Group>()
    
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
    
    
    // GROUP functions
    func addGroup (withTitle title: String) -> Group? {
        let newGroup = Group()
        newGroup.title = title
        realm?.beginWrite()
        _groupList.append(newGroup)
        try? realm?.commitWrite()
        return newGroup
    }
    
    func getGroupCount () -> Int{
        return _groupList.count
    }
    
    func getGroup (atIndex index: Int) -> Group? {
        guard index >= 0 && index <= getGroupCount() else {return nil}
        return _groupList[index]
    }
    
    func getGroupIndex (forGroup group: Group) -> Int? {
        return _groupList.index(of: group)
    }
    func modifyGroupTitle (forGroup group: Group, withNewTitle newTitle: String) {
        group.title = newTitle
    }
    
    func removeGroup (atIndex index:Int) {
        realm?.beginWrite()
        _groupList.remove(at: index)
        try? realm?.commitWrite()
    }
}
