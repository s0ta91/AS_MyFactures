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
    
    func selectDefaultRow (forCategoryName categoryName: String, forPickerView pickerView: UIPickerView) {
//        guard let manager = _manager else { fatalError("Manager cannot be found")}
//        guard let category = _manager?.getCategory(forName: categoryName) else { fatalError("Cannot find any category with name :\(categoryName)") }
        guard let category = Manager.instance.getCategory(forName: categoryName) else { fatalError("Cannot find any category with name :\(categoryName)") }
        
        // There is one hidden category so the number of rows is minus 1
        pickerView.selectRow(Manager.instance.getCategoryIndex(forCategory: category) - 1, inComponent: 0, animated: false)
    }
}

extension CategoryPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowInComponentCategory: Int = 0
        if let manager = _manager {
            // There is one hidden category so the number of rows is minus 1
            numberOfRowInComponentCategory = manager.getCategoryCount() - 1
        }
        return numberOfRowInComponentCategory
    }
    
    
}

extension CategoryPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // First category title must never be shown in the pickerView
        return getCategoryTitle(forRow: row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // First category title must never be shown in the pickerView
        let categoryTitle = getCategoryTitle(forRow: row + 1)
        if categoryTitle != nil {
            _categoryTextField.text = categoryTitle
        }else {
            _categoryTextField.text = "Error"
        }
    }
}
