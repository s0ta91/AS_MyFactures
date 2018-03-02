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
    private var _groupArray: [String] = []

    
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
        let newGroupIndex = getNewGroupIndex(withTitle: title)
        let newGroup = Group()
        newGroup.title = title
        realm?.beginWrite()
        _groupList.insert(newGroup, at: newGroupIndex)
        try? realm?.commitWrite()
        return newGroup
    }
    //TODO: - Create function to know at which index the new group has to be inserted in order to the list to be sorted
    private func getNewGroupIndex (withTitle title: String) -> Int {
        var groupIndex: Int?
        for index in 0..<_groupList.count {
            if let group = getGroup(atIndex: index) {
                let groupName = group.title
                _groupArray.append(groupName)
            }
        }
        _groupArray.append(title)
        _groupArray.sort()
        groupIndex = _groupArray.index(of: title)!
        return groupIndex!
    }
    
    func getGroupCount () -> Int{
        return _groupList.count
    }
    
    func getGroup (atIndex index: Int) -> Group? {
        return _groupList[index]
    }
    
    func getGroupIndex (forGroup group: Group) -> Int? {
        return _groupList.index(of: group)
    }
    func getGroup (forName groupName: String) -> Group? {
        var group: Group? = nil
        let groupPredicate = NSPredicate(format: "_title == %@", groupName)
        if let groupIndex = _groupList.index(matching: groupPredicate) {
            group = getGroup(atIndex: groupIndex)
        }
        return group
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
