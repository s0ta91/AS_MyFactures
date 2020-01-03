//
//  Group.swift
//  MyFactures
//
//  Created by Sébastien Constant on 03/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class Group: NSManagedObject {
    let context = Manager.instance.context
    
    private var _monthList: [Month] = []
//    private var _monthList: [Month] {
//        let monthRequest: NSFetchRequest<Month> = Month.fetchRequest()
//        do {
//            return try Manager.instance.context.fetch(monthRequest)
//        } catch (let error) {
//            print("Error fetching groups from DB: \(error)")
//            return [Month]()
//        }
//    }
    
    // MARK: - PUBLIC
    
    func getMonth (atIndex index: Int) -> Month? {
        let month: Month?
        if index >= 0 && index < getMonthCount() {
            month = _monthList[index]
        }else {
            month = nil
        }
        return month
        
    }
    
    func getMonthCount () -> Int{
        return _monthList.count
    }
    
    func getMonthIndexFromTable (forMonthName monthName: String) -> Int {
        return Manager.instance._monthArray.firstIndex(of: monthName)!
    }
    
    func updateDecemberName() {
        if let month = getMonth(atIndex: getMonthIndexFromTable(forMonthName: NSLocalizedString("December", comment: ""))) {
            month.month = NSLocalizedString("December", comment: "")
        }
    }
}
