//
//  Year.swift
//  MyFactures
//
//  Created by Sébastien Constant on 03/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class YearCD: NSManagedObject {

    
    private var _cdGroupList: [GroupCD] {
        get {
            let yearPredicate = NSPredicate(format: "year == %@", self)
            let groupRequest: NSFetchRequest<GroupCD> = GroupCD.fetchRequest()
            groupRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            groupRequest.predicate = yearPredicate
            do {
                return try Manager.instance.context.fetch(groupRequest)
            } catch (let error) {
                print("Error fetching groups from DB: \(error)")
                return [GroupCD]()
            }
        }
        set {}
    }
    private var _groupListToShow : [GroupCD] = []
    
    // MARK: - PUBLIC
    func addGroup(withTitle title: String, totalPrice: Double? = 0, totalDocuments: Int64? = 0, isListFiltered: Bool) -> GroupCD {
        let newGroup = GroupCD(context: Manager.instance.context)
        newGroup.title = title
        if let totalPrice = totalPrice,
            let totalDocuments = totalDocuments {
            newGroup.totalPrice = totalPrice
            newGroup.totalDocuments = totalDocuments
            newGroup.year = self
            print("Init group list")
            newGroup.initMonthList()
            print("new month count \(newGroup.getMonthCount())")
        }
        _cdGroupList.append(newGroup)
        print("---> groupList updated: Contains \(_cdGroupList.count) group(s)")
        Manager.instance.saveCoreDataContext()
        
        setGroupList()
        return newGroup
    }
    
    func getGroup(atIndex index: Int, isListFiltered: Bool = false) -> GroupCD? {
        if isListFiltered == true {
            return _groupListToShow[index]
        }else {
//            print("\(year): return group \(String(describing: _cdGroupList[index].title))")
//            print("groupMonths: \(_cdGroupList[index].getMonthInfos())")
            return _cdGroupList[index]
        }
    }
    
    func getGroup(forName groupName: String, isListFiltered: Bool = false) -> GroupCD? {
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
    
    func getGroupIndex(forGroup group: GroupCD) -> Int? {
        return _cdGroupList.firstIndex(of: group)
    }
    
    func modifyGroupTitle (forGroup group: GroupCD, withNewTitle newTitle: String) {
        group.title = newTitle
        Manager.instance.saveCoreDataContext()
        setGroupList()
    }
    
//    func removeGroup(atIndex index:Int) {
//        let groupToDelete = _cdGroupList[index]
//        manager.context.delete(groupToDelete)
//        _groupListToShow.remove(at: index)
//        manager.saveCoreDataContext()
//    }
    
    func removeGroup(_ groupToDelete: GroupCD) {
        if let groupIndex = _groupListToShow.firstIndex(of: groupToDelete) {
            _groupListToShow.remove(at: groupIndex)
        }
        
        Manager.instance.context.delete(groupToDelete)
        Manager.instance.saveCoreDataContext()
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
    }
    
    func getGlobalGroupCount() -> Int {
        return _groupListToShow.count
    }
    
    func getGroupCount() -> Int {
        return _groupListToShow.count
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