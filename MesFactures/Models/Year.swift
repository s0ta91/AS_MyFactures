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
    private var _groupListToShow : [Group] = []

    
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
        setGroupList()
        return newGroup
    }
    //TODO: - Create function to know at which index the new group has to be inserted in order to the list to be sorted
    private func getNewGroupIndex (withTitle title: String) -> Int {
        var groupIndex: Int?
        for index in 0..<_groupList.count {
            if let group = getGroup(atIndex: index, withFilter: false) {
                let groupName = group.title
                _groupArray.append(groupName)
            }
        }
        _groupArray.append(title)
        _groupArray.sort()
        groupIndex = _groupArray.index(of: title)!
        _groupArray.removeAll()
        return groupIndex!
    }
    
    func checkForDuplicate (forGroupName groupName: String) -> Bool {
        var groupNameExists: Bool = false
        for groupIndex in 0..<getGroupCount() {
            if let existingGroupToCheck = getGroup(atIndex: groupIndex) {
                if groupName == existingGroupToCheck.title {
                    groupNameExists = true
                }
            }
        }
        return groupNameExists
    }
    
    
    func getGroupCount () -> Int{
        return _groupListToShow.count
    }
    
    func getGroup (atIndex index: Int, withFilter filter: Bool = true) -> Group? {
        if filter == true {
            return _groupListToShow[index]
        }else {
            return _groupList[index]
        }
    }
    
    func setGroupList (containing nameParts: String = ""){
        _groupListToShow.removeAll(keepingCapacity: false)
        var groupResults: Results<Group>
        if nameParts != "" {
            let groupIndexPredicate = NSPredicate(format: "_title CONTAINS[cd] %@", nameParts)
            groupResults = _groupList.filter(groupIndexPredicate)
        }else {
            groupResults = _groupList.filter("TRUEPREDICATE")
        }
        for group in groupResults {
            _groupListToShow.append(group)
        }
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
