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
    
    var _group: Group?
    
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
        guard let group = _group else {
            // FIXME: - Créer une modale d'erreur pour demander de relancer l'application
            fatalError("Group cannot be found")
        }
        return group.getMonthCount()
    }
}

extension MonthsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let group = _group else { fatalError("Group cannot be found") }
        return group.getMonth(atIndex: row)?.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let group = _group else { fatalError("Group cannot be found") }
        guard let monthName = group.getMonth(atIndex: row)?.name else {
            // FIXME: - Créer une modale d'erreur pour demander de relancer l'application
            fatalError("Cannot retreive monthName for index: \(row)")
        }
        _monthTextField.text = monthName
    }
}
