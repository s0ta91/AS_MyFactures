//
//  Year.swift
//  MyFactures
//
//  Created by Sébastien Constant on 03/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class Year: NSManagedObject {

    let manager = Manager.instance
    private var _cdGroupList: [Group] {
        let groupRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            return try Manager.instance.context.fetch(groupRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [Group]()
        }
    }
    private var _groupListToShow : [Group] = []
    
    // MARK: - PUBLIC
    func addGroup(withTitle title: String, isListFiltered: Bool) -> Group? {
        let newGroup = Group(context: manager.context)
        newGroup.title = title
        
        manager.saveCoreDataContext()
        
        newGroup.initMonthList()
        setGroupList()
        return newGroup
    }
    
    func getGroup(atIndex index: Int, isListFiltered: Bool = false) -> Group? {
        if isListFiltered == true {
            return _groupListToShow[index]
        }else {
            return _cdGroupList[index]
        }
    }
    
    func getGroup(forName groupName: String, isListFiltered: Bool = false) -> Group? {
        if isListFiltered {
            guard let group = _groupListToShow.first(where: { (group) -> Bool in
                group.title?.lowercased() == groupName.lowercased()
            }) else { return nil }
            return group
        } else {
            guard let group = _cdGroupList.first(where: { (group) -> Bool in
                group.title?.lowercased() == groupName.lowercased()
            }) else { return nil }
            return group
        }
    }
    
    func getGroupIndex(forGroup group: Group) -> Int? {
        return _cdGroupList.firstIndex(of: group)
    }
    
    func modifyGroupTitle (forGroup group: Group, withNewTitle newTitle: String) {
        group.title = newTitle
        manager.saveCoreDataContext()
        setGroupList()
    }
    
//    func removeGroup(atIndex index:Int) {
//        let groupToDelete = _cdGroupList[index]
//        manager.context.delete(groupToDelete)
//        _groupListToShow.remove(at: index)
//        manager.saveCoreDataContext()
//    }
    
    func removeGroup(_ groupToDelete: Group) {
        if let groupIndex = _cdGroupList.firstIndex(of: groupToDelete) {
            _groupListToShow.remove(at: groupIndex)
        }
        
        manager.context.delete(groupToDelete)
        manager.saveCoreDataContext()
    }
    
    func setGroupList(containing nameParts: String = "") {
        _groupListToShow.removeAll(keepingCapacity: false)
        _groupListToShow = _cdGroupList
        if !nameParts.isEmpty {
            _groupListToShow.removeAll()
            _groupListToShow = _cdGroupList.filter { (group) -> Bool in
                guard let title = group.title else { return false }
                return title.contains(nameParts)
            }
        }
        
        _cdGroupList.forEach { (group) in
            group.updateDecemberName()
        }
    }
    
    func getGlobalGroupCount() -> Int {
        return _groupListToShow.count
    }
    
    func getGroupCount() -> Int {
        return _cdGroupList.count
    }
    
    func checkForDuplicate(forGroupName groupName: String) -> Bool {
        var groupNameExists: Bool = false
        
        _groupListToShow.forEach { (group) in
            guard group.title?.lowercased() == groupName.lowercased() else { return }
            groupNameExists = true
        }
        return groupNameExists
    }
    
    func groupExist(forGroupName groupName: String) -> Bool {
        guard let _ = _cdGroupList.filter({ (group) -> Bool in
            group.title?.lowercased() == groupName.lowercased()
        }).first else { return false }
        return true
    }
}
