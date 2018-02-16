//
//  YearsPicker.swift
//  MesFactures
//
//  Created by Sébastien on 16/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class YearsPicker: UIPickerView {

    let monthArray = ["Janvier", "Févier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    
    var _manager: Manager?
    var _yearsTexField: UITextField!
    var _monthTextField: UITextField!
}

extension YearsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return monthArray.count
        }else {
            var _numberOfRowForComponentYear: Int = 0
            if let manager = _manager {
                _numberOfRowForComponentYear = manager.getyearsCount()
            }
            return _numberOfRowForComponentYear
        }
    }
}

extension YearsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return monthArray[row]
        }else {
            let stringYear: String?
            if let manager = _manager,
                let intYear = manager.getYear(atIndex: row) {
                stringYear = String(describing: intYear.year)
            }else {
                stringYear = nil
            }
            return stringYear
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var month: String = ""
        var year: String = ""
        if component == 0 {
            month = monthArray[row]
        }else {
            if let manager = _manager,
                let selectedYear = manager.getYear(atIndex: row){
                year = String(describing: selectedYear.year)
            }
        }
        _monthTextField.text = month
        _yearsTexField.text = year
    }
}
