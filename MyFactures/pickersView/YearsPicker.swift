//
//  YearsPicker.swift
//  MyFactures
//
//  Created by Sébastien on 29/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class YearsPicker: UIPickerView {

    let _manager = DbManager().getDb()
    var _yearTextField: UITextField!
    
    private func getYear(forRow row: Int) -> String? {
        guard let year = _manager?.getYear(atIndex: row)?.year else { return nil }
        return String(year)
    }

}

extension YearsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _manager!.getyearsCount()
    }
}

extension YearsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getYear(forRow: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = getYear(forRow: row)
        if year != nil {
            _yearTextField.text = year
        } else {
            _yearTextField.text = "Error"
        }
    }
}
