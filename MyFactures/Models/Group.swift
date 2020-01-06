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
    
    let manager = Manager.instance
    
    //private var _monthList: [Month] = []
    private var _monthList: [Month] {
        let monthRequest: NSFetchRequest<Month> = Month.fetchRequest()
        do {
            return try Manager.instance.context.fetch(monthRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [Month]()
        }
    }
    
    // MARK: - PUBLIC
    
    func addMonth(_ monthName: String) {
        let newMonth = Month(context: manager.context)
        newMonth.name = monthName
        manager.saveCoreDataContext()
    }
    
    func getMonthCount() -> Int{
        return _monthList.count
    }
    
    func initMonthList() {
        manager._monthArray.forEach { (monthName) in
            addMonth(monthName)
        }
    }
    
    func getMonth(atIndex index: Int) -> Month? {
        let month: Month?
        if index >= 0 && index < getMonthCount() {
            month = _monthList[index]
        }else {
            month = nil
        }
        return month
        
    }
    
    func getMonthIndexFromTable(forMonthName monthName: String) -> Int {
        return Manager.instance._monthArray.firstIndex(of: monthName)!
    }
    
    func checkIfMonthExist(forMonthName monthName: String) -> Month? {
        guard let monthIndex = manager._monthArray.firstIndex(of: monthName),
            let monthToReturn = getMonth(atIndex: monthIndex) else {
                print("--> Error: This month name is unknown or does not exists in database")
                return nil
        }
        return monthToReturn
    }

    func getTotalGroupAmount() -> Double {
        var totalAmount: Double = 0
        for month in _monthList {
            totalAmount += month.totalAmount
        }
        return totalAmount
    }
    
    func getTotalDocument() -> Int64 {
        var totalDocument: Int64 = 0
        _monthList.forEach { (month) in
            totalDocument += month.totalDocument
        }
        return totalDocument
    }
    
    func updateDecemberName() {
        if let month = getMonth(atIndex: getMonthIndexFromTable(forMonthName: NSLocalizedString("December", comment: ""))) {
            month.name = NSLocalizedString("December", comment: "")
        }
    }
}
