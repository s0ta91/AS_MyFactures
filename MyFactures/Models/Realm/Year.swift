//
//  RealmYear.swift
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
    var _groupListToShow : [Group] = []

    
    var year: Int {
        get {
            return _year
        }set {
            realm?.beginWrite()
            _year = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    var selected: Bool {
        get {
            return _selected
        }set {
            realm?.beginWrite()
            _selected = newValue
            ((try? realm?.commitWrite()) as ()??)
        }
    }
    
    
    // GROUP functions
    func addGroup (withTitle title: String, _ isListFiltered: Bool) -> Group? {
        let newGroupIndex = getNewGroupIndex(withTitle: title, isListFiltered)
        let newGroup = Group()
        newGroup.title = title
        do {
            try realm?.write {
                _groupList.insert(newGroup, at: newGroupIndex)
            }
        } catch (let error) {
            print("can't add/insert this new group: \(error)")
        }
        newGroup.initMonthList()
        setGroupList()
        return newGroup
    }
    
    //TODO: - Create function to know at which index the new group has to be inserted in order to sorted the list
    private func getNewGroupIndex (withTitle title: String, _ isListFileterd: Bool) -> Int {
        var groupIndex: Int?
        for index in 0..<_groupList.count {
            if let group = getGroup(atIndex: index) {
                let groupName = group.title.lowercased()
                _groupArray.append(groupName)
            }
        }
        _groupArray.append(title.lowercased())
        _groupArray.sort()
        groupIndex = _groupArray.firstIndex(of: title.lowercased())!
        _groupArray.removeAll()
        return groupIndex!
    }
    
    func checkForDuplicate (forGroupName groupName: String, _ isListFiltered: Bool) -> Bool {
        var groupNameExists: Bool = false
        for groupIndex in 0..<getGroupCount() {
            if let existingGroupToCheck = getGroup(atIndex: groupIndex, isListFiltered) {
                if groupName.lowercased() == existingGroupToCheck.title.lowercased() {
                    groupNameExists = true
                }
            }
        }
        return groupNameExists
    }
    
    func getGlobalGroupCount () -> Int {
        return _groupList.count
    }
    
    func getGroupCount () -> Int{
        return _groupListToShow.count
    }
    
    func getGroup (atIndex index: Int, _ isListFiltered: Bool = false) -> Group? {
        if isListFiltered == true {
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
            group.updateDecemberMonthName()
            _groupListToShow.append(group)
        }
    }
    
    func getGroupIndex (forGroup group: Group) -> Int? {
        return _groupList.index(of: group)
    }
    
    func getGroup (forName groupName: String, _ isListFiltered: Bool = false) -> Group? {
        var group: Group? = nil
        let groupPredicate = NSPredicate(format: "_title == %@", groupName)
        if let groupIndex = _groupList.index(matching: groupPredicate) {
            group = getGroup(atIndex: groupIndex, isListFiltered)
        }
        return group
    }
    
    func modifyGroupTitle (forGroup group: GroupCD, withNewTitle newTitle: String) {
        group.title = newTitle
    }
    
    func groupExist(forGroupName groupName: String) -> Bool {
        return _groupList.filter(NSPredicate(format: "_title == %@", groupName)).isEmpty ? false : true
    }
    
    func removeGroup (atIndex index:Int) {
        if let groupToDelete = getGroup(atIndex: index) {
            do {
                try realm?.write {
                    realm?.delete(groupToDelete)
                }
            }catch{
                print("can't delete group at index :\(index)")
            }
        }else {
            print("This group at index '\(index)' does not exists")
        }
    }
    
    func removeGroupinListToShow (atIndex index: Int) {
        _groupListToShow.remove(at: index)
    }
}

