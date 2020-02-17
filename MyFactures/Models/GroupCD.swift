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
    
    private var _monthList: [MonthCD] {
        let monthRequest: NSFetchRequest<MonthCD> = MonthCD.fetchRequest()
        let monthPredicate = NSPredicate(format: "group == %@", self)
        monthRequest.predicate = monthPredicate
        monthRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        do {
            return try Manager.instance.context.fetch(monthRequest)
        } catch (let error) {
            print("Error fetching groups from DB: \(error)")
            return [MonthCD]()
        }
    }
    
    
    // MARK: - Public
    func initMonthList() {
        var monthNumber: Int64 = 0
        manager._monthArray.forEach { (monthName) in
            monthNumber += 1
            addMonth(monthNumber, monthName)
        }
    }
    
    func addMonth(_ number: Int64, _ monthName: String) {
        let newMonth = MonthCD(context: manager.context)
        newMonth.number = number
        newMonth.name = monthName
        newMonth.group = self
        manager.saveCoreDataContext()
    }
    
    func getMonthInfos() {
        _monthList.forEach { (month) in
            print("monthNumber: \(month.number)")
            print("monthName: \(month.name)")
            print("monthTotalDoc: \(month.totalDocument)")
            print("monthTotalAmount: \(month.totalAmount)")
        }
    }
    
    func getMonthCount() -> Int{
        return _monthList.count
    }
    
    func getMonth(atIndex index: Int) -> MonthCD? {
        guard index >= 0 && index < getMonthCount() else { return nil }
        return _monthList[index]
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
    
//    func update() {
//        totalPrice = 0
//        totalDocuments = 0
//        _monthList.forEach { (month) in
//            totalPrice += month.totalAmount
//            totalDocuments += month.totalDocument
//        }
//    }
    
    func getTotalAmount() -> Double {
//        var totalAmount: Double = 0
        totalPrice = 0
        for month in _monthList {
            totalPrice += month.totalAmount
        }
        return totalPrice
    }
    
    func getTotalDocuments() -> Int64 {
        totalDocuments = 0
        _monthList.forEach { (month) in
            totalDocuments += month.totalDocument
        }
        return totalDocuments
    }
}
