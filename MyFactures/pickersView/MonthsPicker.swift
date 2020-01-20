//
//  MonthsPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class MonthsPicker: UIPickerView {

    var _monthTextField: UITextField!
    
    func selectDefaultRow (forMonthName monthName: String, forPickerView pickerView: UIPickerView) {
        let monthIndex = Manager.instance.getMonthIndexFromTable(forMonthName: monthName)
        pickerView.selectRow(monthIndex, inComponent: 0, animated: false)
    }
}

extension MonthsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Manager.instance.getMonthCount()
    }
}

extension MonthsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Manager.instance.getMonth(atIndex: row)?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let monthName = Manager.instance.getMonth(atIndex: row)?.name else {
            // FIXME: - Créer une modale d'erreur pour demander de relancer l'application
            fatalError("Cannot retreive monthName for index: \(row)")
        }
        _monthTextField.text = monthName
    }
}
