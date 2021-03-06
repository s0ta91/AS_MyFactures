//
//  GroupPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupPicker: UIPickerView {

    var _year: Year?
    var _groupTextField: UITextField!
    
    func getGroupTitle(forRow row: Int) -> String? {
        var groupTitle: String?
        if let year = _year,
            let group = year.getGroup(atIndex: row) {
            groupTitle = group.title
        }
        return groupTitle
    }
    
    func selectDefaultRow (forGroupName groupName: String, forPickerView pickerView: UIPickerView) {
        guard let year = _year else { fatalError("Year cannot be found") }
        guard let group = year.getGroup(forName: groupName) else { fatalError("Group cannot be found for name: \(groupName)")}
        pickerView.selectRow(year.getGroupIndex(forGroup: group)!, inComponent: 0, animated: false)
    }
}

extension GroupPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowInComponentGroup: Int = 0
        if let year = _year {
            numberOfRowInComponentGroup = year.getGlobalGroupCount()
        }
        return numberOfRowInComponentGroup
    }
}

extension GroupPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getGroupTitle(forRow: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let groupTitle = getGroupTitle(forRow: row)
        if groupTitle != nil {
            _groupTextField.text = groupTitle
        }else {
            _groupTextField.text = "Error"
        }
    }

}


