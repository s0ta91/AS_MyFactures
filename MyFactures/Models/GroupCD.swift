//
//  Group.swift
//  MyFactures
//
//  Created by Sébastien Constant on 03/01/2020.
//  Copyright © 2020 Sébastien Constant. All rights reserved.
//

import Foundation
import CoreData

public class GroupCD: NSManagedObject {
    
    let manager = Manager.instance
    let ALL_CATEGORY_TEXT = NSLocalizedString("All categories", comment: "")
    
    private var _monthList: [MonthCD] {
        let monthRequest: NSFetchRequest<MonthCD> = MonthCD.fetchRequest()
        do {
            return try Manager.instance.context.fetch(monthRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [MonthCD]()
        }
    }
    
    
    // MARK: - Public
    func addMonth(_ monthName: String) {
        let newMonth = MonthCD(context: manager.context)
        newMonth.name = monthName
        manager.saveCoreDataContext()
    }
    
    func getMonthCount() -> Int{
        return _monthList.count
    }
    
    func getMonth(atIndex index: Int) -> MonthCD? {
        let month: MonthCD?
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
    
    func checkIfMonthExist(forMonthName monthName: String) -> MonthCD? {
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
}
