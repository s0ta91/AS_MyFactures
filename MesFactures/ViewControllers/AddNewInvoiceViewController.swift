//
//  AddNewInvoiceViewController.swift
//  MesFactures
//
//  Created by Sébastien on 15/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class AddNewInvoiceViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var ui_thumbnailView: UIImageView!
    @IBOutlet weak var ui_descriptionTextField: UITextField!
    @IBOutlet weak var ui_monthSelectionTextField: UITextField!
    @IBOutlet weak var ui_yearSelectionTextField: UITextField!
    @IBOutlet weak var ui_groupSelectionTextField: UITextField!
    @IBOutlet weak var ui_categorySelectionTextField: UITextField!
    @IBOutlet weak var ui_amounttextField: UITextField!
    
    //MARK: - paththrough Managers/Objects
    var _ptManager: Manager?
    var _ptYear: Year?
    var _ptGroup: Group?
    
    //MARK: - Global variable filled with passthrough Managers/objects
    private var _manager: Manager!
    private var _year: Year!
    private var _group: Group!
    
    private var yearsPickerView: YearsPicker!
    
    //TODO: Create PickerView
    var pickerView = UIPickerView()
    //TODO: Create array of month
//    let monthArray = ["Janvier", "Févier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    //TODO: Create array to hold data to use
    var currentArray: [String] = []
    //TODO: Create variable to hold textField in use
    var activeTextField: UITextField!
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_yearSelectionTextField.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkReceivedData()
        setSeparatorForFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Private functions
    private func checkReceivedData () {
        if let recievedManager = _ptManager,
            let recievedYear = _ptYear,
            let recievedGroup = _ptGroup {
            _manager = recievedManager
            _year = recievedYear
            _group = recievedGroup
        }else {
            fatalError("Error recieving path_through managers/objects")
        }
    }

    private func setSeparatorForFields () {
        ui_descriptionTextField.underlined()
        ui_yearSelectionTextField.underlined()
        ui_monthSelectionTextField.underlined()
        ui_groupSelectionTextField.underlined()
        ui_categorySelectionTextField.underlined()
    }

    
    
    @IBAction func ui_addNewInvoiceButtonPressed(_ sender: UIButton) {
        
    }

    @IBAction func cancelVCButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extensions

extension AddNewInvoiceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == ui_yearSelectionTextField {
            yearsPickerView = YearsPicker()
            ui_yearSelectionTextField.inputView = pickerView
            pickerView.delegate = yearsPickerView
            yearsPickerView._manager = _manager
            yearsPickerView._yearsTexField = ui_yearSelectionTextField
            yearsPickerView._monthTextField = ui_monthSelectionTextField
        }
        if textField == ui_groupSelectionTextField {
            
        }
        if textField == ui_categorySelectionTextField {
            
        }
        return true
    }
}

//TODO: textField & Label extension
extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
