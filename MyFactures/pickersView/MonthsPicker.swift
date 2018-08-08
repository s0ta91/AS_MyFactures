//
//  MonthsPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class MonthsPicker: UIPickerView {

    var _group: Group?
//    let monthArray = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    
    var _monthTextField: UITextField!

    func selectDefaultRow (forMonthName monthName: String, forPickerView pickerView: UIPickerView) {
        guard let group = _group else { fatalError("Group cannot be found") }
        let monthIndex = group.getMonthIndexFromTable(forMonthName: monthName)
        pickerView.selectRow(monthIndex, inComponent: 0, animated: false)
    }
}

extension MonthsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let group = _group else { fatalError("Group cannot be found") }
        return group.getMonthCount()
    }
}

extension MonthsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let group = _group else { fatalError("Group cannot be found") }
        return group.getMonth(atIndex: row)?.month
//        return monthArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let group = _group else { fatalError("Group cannot be found") }
        guard let monthName = group.getMonth(atIndex: row)?.month else { fatalError("Cannot retreive monthName for index: \(row)")}
        _monthTextField.text = monthName
//        _monthTextField.text = monthArray[row]
    }
}
