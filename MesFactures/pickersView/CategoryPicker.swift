//
//  CategoryPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class CategoryPicker: UIPickerView {

    var _manager: Manager?
    var _categoryTextField: UITextField!
    
    func getCategoryTitle(forRow row: Int) -> String? {
        var categoryTitle: String?
        if let manager = _manager,
            let category = manager.getCategory(atIndex: row) {
                categoryTitle = category.title
        }
        return categoryTitle
    }
}

extension CategoryPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowInComponentCategory: Int = 0
        if let manager = _manager {
            numberOfRowInComponentCategory = manager.getCategoryCount()
        }
        print("catRow: \(numberOfRowInComponentCategory)")
        return numberOfRowInComponentCategory
    }
    
    
}

extension CategoryPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getCategoryTitle(forRow: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categoryTitle = getCategoryTitle(forRow: row)
        if categoryTitle != nil {
            _categoryTextField.text = categoryTitle
        }else {
            _categoryTextField.text = "Error"
        }
    }
}
