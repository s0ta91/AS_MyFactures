//
//  YearsPicker.swift
//  MesFactures
//
//  Created by Sébastien on 16/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class YearsPicker: UIPickerView {

    var _manager: Manager?
    var _yearsTexField: UITextField!
    
}

extension YearsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var _numberOfRowForComponentYear: Int = 0
        if let manager = _manager {
            _numberOfRowForComponentYear = manager.getyearsCount()
        }
        return _numberOfRowForComponentYear
    }
}

extension YearsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let stringYear: String?
        if let manager = _manager,
            let intYear = manager.getYear(atIndex: row) {
            stringYear = String(describing: intYear.year)
        }else {
            stringYear = nil
        }
        return stringYear
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var year: String = ""
        if let manager = _manager,
            let selectedYear = manager.getYear(atIndex: row){
            year = String(describing: selectedYear.year)
        }
        _yearsTexField.text = year
    }
}
