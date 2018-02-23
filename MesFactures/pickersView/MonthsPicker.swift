//
//  MonthsPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class MonthsPicker: UIPickerView {

    let monthArray = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    
    var _monthTextField: UITextField!
}

extension MonthsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return monthArray.count
    }
}

extension MonthsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return monthArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _monthTextField.text = monthArray[row]
    }
}
