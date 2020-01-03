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
    func addGroup(withTitle title: String, _ isListFiltered: Bool) -> Group? {
        let newGroup = Group(context: manager.context)
        newGroup.title = title
        
        manager.saveCoreDataContext()
        
        setGroupList()
        return newGroup
    }
    
    func setGroupList (containing nameParts: String = "") {
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
}
