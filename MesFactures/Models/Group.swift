//
//  Group.swift
//  MesFactures
//
//  Created by Sébastien on 04/01/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {
    
    @objc private dynamic var _title = ""
    @objc private dynamic var _totalPrice = 0.0
    @objc private dynamic var _totalDocuments = 0
    private var _monthList = List<Month>()
    let _monthArray = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    
    var title: String {
        get {
            return _title
        }
        set {
            realm?.beginWrite()
            _title = newValue
            try? realm?.commitWrite()
        }
    }
    
    var totalPrice: Double {
        get {
            return _totalPrice
        }set {
            realm?.beginWrite()
            _totalPrice = newValue
            try? realm?.commitWrite()
        }
    }
    
    var totalDocuments: Int {
        get {
            return _totalDocuments
        }set {
            realm?.beginWrite()
            _totalDocuments = newValue
            try? realm?.commitWrite()
        }
    }
    
    // MONTH Functions
    func getMonthCount () -> Int{
        return _monthList.count
    }
    
    func addMonth (_ monthName: String) {
        let newMonth = Month()
        newMonth.month = monthName
        realm?.beginWrite()
        _monthList.append(newMonth)
        try? realm?.commitWrite()
    }
    
    func getMonth (atIndex index: Int) -> Month? {
        let month: Month?
        if index >= 0 && index < getMonthCount() {
            month = _monthList[index]
        }else {
            month = nil
        }
        return month
    }
    func getMonthIndex (forMonth month: Month) -> Int? {
        return _monthList.index(of: month)
    }
    func getMonthIndexFromTable (forMonthName monthName: String) -> Int! {
        return _monthArray.index(of: monthName)
    }
    
    func removeMonth (atIndex index: Int) {
        if let monthToDelete = getMonth(atIndex: index) {
            realm?.beginWrite()
            realm?.delete(monthToDelete)
            try? realm?.commitWrite()
        }
    }
    
    func checkIfMonthExist (forMonthName monthName: String) -> Month {
        let monthToReturn: Month
        let monthArray = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
        guard let monthIndex = monthArray.index(of: monthName) else { fatalError("This month name is unknown") }
        if let monthObject = getMonth(atIndex: monthIndex) {
            monthToReturn = monthObject
        }else {
            fatalError("month :\(monthName) does not exists in database")
        }
        return monthToReturn
    }
    
    func getTotalGroupAmount () -> Double {
        var totalAmount: Double = 0
        for month in _monthList {
            if let monthIndex = getMonthIndex(forMonth: month) {
                totalAmount = totalAmount + month.getTotalAmount(forMonthIndex: monthIndex)
            }
        }
        return totalAmount
    }
    
    func getTotalDocument () -> Int {
        var totalDocument: Int = 0
        for month in _monthList {
            totalDocument = totalDocument + month.getInvoiceCount()
        }
        return totalDocument
    }
}
