//
//  CategoryPicker.swift
//  MesFactures
//
//  Created by Sébastien on 19/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class CategoryPicker: UIPickerView {

    var _categoryTextField: UITextField!
    
    func getCategoryTitle(forRow row: Int) -> String {
        let categories = Manager.instance.getPickerCategories()
        return categories[row]
    }
    
    func selectDefaultRow (forCategoryName categoryName: String, forPickerView pickerView: UIPickerView) {
//        guard let manager = _manager else { fatalError("Manager cannot be found")}
//        guard let category = _manager?.getCategory(forName: categoryName) else { fatalError("Cannot find any category with name :\(categoryName)") }
        guard let category = Manager.instance.getCategory(forName: categoryName) else { fatalError("Cannot find any category with name :\(categoryName)") }
        guard let index = Manager.instance.getCategoryIndex(forCategory: category) else { fatalError("Cannot find index for category :\(categoryName)") }
        // There is one hidden category so the number of rows is minus 1
        
        pickerView.selectRow(index - 1, inComponent: 0, animated: false)
    }
}

extension CategoryPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRowInComponentCategory: Int = 0
        // There is one hidden category so the number of rows is minus 1
        numberOfRowInComponentCategory = (Manager.instance.getTopCategoryCount() - 1) + Manager.instance.getCategoryCount()
        return numberOfRowInComponentCategory
    }
    
    
}

extension CategoryPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // First category title must never be shown in the pickerView
        return getCategoryTitle(forRow: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // First category title must never be shown in the pickerView
        _categoryTextField.text = getCategoryTitle(forRow: row)
        
    }
}
