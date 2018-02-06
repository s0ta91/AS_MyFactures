//
//  Manager.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainAccess

class Manager {
    
    private var _realm: Realm
    private var _yearsList: Results<Year>
    private var _applicationDataList: Results<ApplicationData>
    private var _groupList: Results<Group>
    
    /** INIT functions **/
    init (withRealm realm: Realm) {
        _realm = realm
        _yearsList = _realm.objects(Year.self).sorted(byKeyPath: "_year", ascending: false)
        _applicationDataList = _realm.objects(ApplicationData.self)
        _groupList = _realm.objects(Group.self).sorted(byKeyPath: "_title")
    }
    
    func initYear () {
        let _currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: _currentDate)
        if getApplicationDataCount() == 0 {
            let yearsStartAt = 1900
            for calculatedYears in yearsStartAt...currentYear {
                addYear(calculatedYears)
            }
        _yearsList.first?.selected = true
        }else {
            if let yearsListLast = _yearsList.first,
                yearsListLast.year != currentYear {
                addYear(currentYear)
            }
        }
    }
    
    
    /** PRIVATE functions **/
    private func getApplicationDataCount () -> Int {
        return _applicationDataList.count
    }
    
    private func addYear (_ yearToAdd: Int) {
        let newYear = Year()
        newYear.year = yearToAdd
        try? _realm.write {
            _realm.add(newYear)
        }
    }
    
    
    /** PUBLIC functions **/
    func savePassword (_ password: String) {
        DbManager().saveMasterPassword(password)
    }
    
    func hasMasterPassword () -> Bool{
        return DbManager().getMasterPassword() != nil
    }
    
    func updateApplicationData () {
        let applicationData = ApplicationData()
        _realm.beginWrite()
        _realm.add(applicationData)
        try? _realm.commitWrite()
    }
    
    // YEAR functions
    func setSelectedYear (forYear newSelectedYear: Year) {
        let oldSelectedYear = getSelectedYear()
        oldSelectedYear?.selected = false
        newSelectedYear.selected = true
    }
    
    func getSelectedYear () -> Year! {
        let selectedYear: Year?
        let findSelectedYear = NSPredicate(format: "_selected == true")
        if let getSelectedYear = _yearsList.filter(findSelectedYear).first {
            selectedYear = getSelectedYear
        }else {
            selectedYear = nil
        }
        return selectedYear
    }
    
    
    // GROUP functions
    func getGroupCount () -> Int{
        return _groupList.count
    }
    
    func addGroup (withTitle title: String) {
        let newGroup = Group()
        newGroup.title = title
        try? _realm.write {
            _realm.add(newGroup)
        }
    }
    
    func getGroup (atIndex index:Int) -> Group? {
        guard index >= 0 && index <= getGroupCount() else {return nil}
        return _groupList[index]
    }
    
    func removeGroup (atIndex index:Int) {
        if let groupToRemove = getGroup(atIndex: index) {
            _realm.delete(groupToRemove)
        }
    }
    
    func convertToCurrencyNumber (forTextField textField: UITextField? = nil, forLabel label: UILabel? = nil) {
        let textFieldToConvert = textField
        let labelToConvert = label
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.locale = NSLocale.autoupdatingCurrent
        if let amountString = textFieldToConvert?.text,
            let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                textFieldToConvert?.text = numberToCurrencyType
            }
        }else if let amountString = labelToConvert?.text,
            let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                labelToConvert?.text = numberToCurrencyType
            }
        }
    }
}
