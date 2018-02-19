//
//  AddNewInvoiceViewController.swift
//  MesFactures
//
//  Created by Sébastien on 15/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddNewInvoiceViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var ui_thumbnailView: UIImageView!
    @IBOutlet weak var ui_descriptionTextField: UITextField!
    @IBOutlet weak var ui_monthSelectionTextField: UITextField!
    @IBOutlet weak var ui_yearSelectionTextField: UITextField!
    @IBOutlet weak var ui_groupSelectionTextField: UITextField!
    @IBOutlet weak var ui_categorySelectionTextField: UITextField!
    @IBOutlet weak var ui_amountTextField: UITextField!
    @IBOutlet var ui_keyboardToolbarView: UIView!
    @IBOutlet weak var ui_documentAddedLabel: UILabel!
    @IBOutlet weak var ui_deleteAddedDocumentButton: UIButton!
    
    //MARK: - paththrough Managers/Objects
    var _ptManager: Manager?
    var _ptYear: Year?
    var _ptGroup: Group?
    
    //MARK: - Global variable filled with passthrough Managers/objects
    private var _manager: Manager!
    private var _year: Year!
    private var _group: Group!
    
    //MARK: - PickerView Initializer
    private var yearsPickerView: YearsPicker!
    private var monthsPickerView: MonthsPicker!
    private var groupPickerView: GroupPicker!
    private var categoryPickerView: CategoryPicker!
    
    //TODO: Create PickerView
    private var _pickerView = UIPickerView()

    //TODO: Create variable to hold textField in use
    private var _activeTextField: UITextField!
    
    private var _pickedDocument: URL?
    private var _documentHasBeenAdded: Bool! = false
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_descriptionTextField.delegate = self
        ui_yearSelectionTextField.delegate = self
        ui_monthSelectionTextField.delegate = self
        ui_groupSelectionTextField.delegate = self
        ui_categorySelectionTextField.delegate = self
        ui_amountTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkReceivedData()
        setSeparatorForFields()
        setAccessoryViewForPickersView()
        setDefaultValueForTextFields()
        updateDocumentInfo()
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
    
    private func setAccessoryViewForPickersView() {
        ui_yearSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_monthSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_groupSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_categorySelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_amountTextField.inputAccessoryView = ui_keyboardToolbarView
    }

    private func setDefaultValueForTextFields () {
        if let firstMonth = _group.getMonth(atIndex: 0),
            let currentYear = _manager.getYear(atIndex: 0) {
                ui_monthSelectionTextField.text = firstMonth.month
                ui_yearSelectionTextField.text = String(describing: currentYear.year)
                ui_groupSelectionTextField.text = _group.title
        }
    }
    
    private func updateDocumentInfo () {
        if _pickedDocument != nil {
            _documentHasBeenAdded = true
        }else {
            _documentHasBeenAdded = false
        }
        
        if _documentHasBeenAdded == false {
            ui_documentAddedLabel.isHidden = true
            ui_deleteAddedDocumentButton.isHidden = true
        }else {
            ui_documentAddedLabel.isHidden = false
            ui_deleteAddedDocumentButton.isHidden = false
        }
    }

    
    //MARK: - IBAction functions
    @IBAction func doneKeyboardViewButtonpressed(_ sender: UIButton) {
        _activeTextField.resignFirstResponder()
        if _activeTextField == ui_amountTextField {
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
        }
    }
    
    @IBAction func addNewDocumentButtonPressed(_ sender: UIButton) {
        // DocumentPickerViewController to selected a document
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)] , in: .import)
//        documentPicker.delegate = self
//        documentPicker.modalPresentationStyle = .formSheet
//        self.present(documentPicker, animated: true, completion: nil)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAddedDocument(_ sender: UIButton) {
        // Delete the reference to the document
        _pickedDocument = nil
        // update UI
        updateDocumentInfo()
    }
    
    
    @IBAction func addNewInvoiceButtonPressed(_ sender: UIButton) {
        if let description = ui_descriptionTextField.text,
            let monthString = ui_monthSelectionTextField.text,
            let amount = ui_amountTextField,
            let convertedAmount = _manager.convertFromCurrencyNumber(forTextField: amount) {
            let amountDouble = Double(truncating: convertedAmount as NSNumber)
            let category = ui_categorySelectionTextField.text
            let month = _group.checkIfMonthExist(forMonthName: monthString)
                SaveManager.saveDocument(documentURL: _pickedDocument, description: description, categoryName: category, amount: amountDouble, month: month)
                dismiss(animated: true, completion: nil)
        }else {
//            print(ui_descriptionTextField.text)
//            print(ui_amountTextField.text)
//            print(ui_monthSelectionTextField.text)
//            print(ui_categorySelectionTextField.text)
//            print(Double(ui_amountTextField.text!))
            print("Something went wrong")
        }
    }

    @IBAction func cancelVCButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extensions
//TODO: - textField Delegate
extension AddNewInvoiceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        _activeTextField = textField
        if textField == ui_monthSelectionTextField {
            monthsPickerView = MonthsPicker()
            ui_monthSelectionTextField.inputView = _pickerView
            _pickerView.delegate = monthsPickerView
            monthsPickerView._monthTextField = ui_monthSelectionTextField
        }
        if textField == ui_yearSelectionTextField {
            yearsPickerView = YearsPicker()
            ui_yearSelectionTextField.inputView = _pickerView
            _pickerView.delegate = yearsPickerView
            yearsPickerView._manager = _manager
            yearsPickerView._yearsTexField = ui_yearSelectionTextField
        }
        if textField == ui_groupSelectionTextField {
            groupPickerView = GroupPicker()
            ui_groupSelectionTextField.inputView = _pickerView
            _pickerView.delegate = groupPickerView
            groupPickerView._year = _year
            groupPickerView._groupTextField = ui_groupSelectionTextField
        }
        if textField == ui_categorySelectionTextField {
            categoryPickerView = CategoryPicker()
            ui_categorySelectionTextField.inputView = _pickerView
            _pickerView.delegate = categoryPickerView
            categoryPickerView._manager = _manager
            categoryPickerView._categoryTextField = ui_categorySelectionTextField
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_descriptionTextField.resignFirstResponder()
        return true
    }
}

extension AddNewInvoiceViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        _pickedDocument = urls.first
        updateDocumentInfo()
    }
}

extension AddNewInvoiceViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        _pickedDocument = Bundle.main.url(forResource: "Boulanger.com", withExtension: "pdf")
        updateDocumentInfo()
    }
}
extension AddNewInvoiceViewController: UINavigationControllerDelegate {
    
}

//TODO: textField extension
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
