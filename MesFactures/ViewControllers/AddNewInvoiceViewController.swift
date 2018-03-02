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
    
    @IBOutlet var ui_createCategoryView: UIView!
    @IBOutlet weak var ui_addNewCategoryTextField: UITextField!
    
    
    @IBOutlet weak var ui_descriptionTextField: UITextField!
    @IBOutlet weak var ui_monthSelectionTextField: UITextField!
    @IBOutlet weak var ui_yearSelectionTextField: UITextField!
    @IBOutlet weak var ui_groupSelectionTextField: UITextField!
    @IBOutlet weak var ui_categorySelectionTextField: UITextField!
    @IBOutlet weak var ui_amountTextField: UITextField!
    @IBOutlet var ui_keyboardToolbarView: UIView!
    @IBOutlet weak var ui_documentAddedLabel: UILabel!
    @IBOutlet weak var ui_deleteAddedDocumentButton: UIButton!
    @IBOutlet weak var ui_addOrModifyButton: UIButton!
    @IBOutlet weak var ui_addNewDocumentButton: UIButton!
    @IBOutlet weak var ui_visualEffect: UIVisualEffectView!
    
    
    //MARK: - paththrough Managers/Objects
    var _ptManager: Manager?
    var _ptYear: Year?
    var _ptGroup: Group?
    var _ptMonth: Month?
    var _ptInvoice: Invoice?
    var _modifyInvoice: Bool = false
    
    //MARK: - Global variable filled with passthrough Managers/objects
    private var _manager: Manager!
    private var _year: Year!
    private var _group: Group!
    private var _month: Month!
    private var _invoice: Invoice!
    
    //MARK: - Others
    //TODO: PickerView Initializer
    private var monthsPickerView: MonthsPicker!
    private var groupPickerView: GroupPicker!
    private var categoryPickerView: CategoryPicker!
    
    //TODO: Create PickerView
    private var _pickerView = UIPickerView()

    //TODO: Create variable to hold textField in use
    private var _activeTextField: UITextField!
    
    private var _pickedDocument: URL?
    private var _documentHasBeenAdded: Bool = false
    private var _deletePreviousDocument: Bool = false
    private var firstLoad: Bool = true
    private var _visualEffect: UIVisualEffect!
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_descriptionTextField.delegate = self
        ui_monthSelectionTextField.delegate = self
        ui_groupSelectionTextField.delegate = self
        ui_categorySelectionTextField.delegate = self
        ui_amountTextField.delegate = self
        ui_createCategoryView.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkReceivedData()
        setSeparatorForFields()
        setAccessoryViewForPickersView()
        setDefaultValueForTextFields()
        updateDocumentInfo()
        ui_visualEffect.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Private functions
    //TODO: Check if data received from previous controller are all set
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
        
        if _modifyInvoice == true {
            if let receivedMonth = _ptMonth,
                let receivedInvoice = _ptInvoice {
                _month = receivedMonth
                _invoice = receivedInvoice
            }else {
                fatalError("Error recieving path_through month/invoice objects")
            }
        }
    }

    //TODO: Add a separator line between all stack view
    private func setSeparatorForFields () {
        ui_descriptionTextField.underlined()
        ui_yearSelectionTextField.underlined()
        ui_monthSelectionTextField.underlined()
        ui_groupSelectionTextField.underlined()
        ui_categorySelectionTextField.underlined()
    }
    
    //TODO: Set the custom view under the keyboard
    private func setAccessoryViewForPickersView() {
        ui_monthSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_groupSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_categorySelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_amountTextField.inputAccessoryView = ui_keyboardToolbarView
    }

    //TODO: Set defaults values for all fields
    private func setDefaultValueForTextFields () {
        if firstLoad == true {
            firstLoad = false
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
            
            if _modifyInvoice == false {
                ui_descriptionTextField.becomeFirstResponder()
                if let firstMonth = _group.getMonth(atIndex: 0),
                    let currentYear = _manager.getYear(atIndex: 0) {
                        ui_monthSelectionTextField.text = firstMonth.month
                        ui_yearSelectionTextField.text = String(currentYear.year)
                        ui_groupSelectionTextField.text = _group.title
                        ui_categorySelectionTextField.text = "Non-classée"
                }
            }else {
                ui_descriptionTextField.text = _invoice.detailedDescription
                ui_yearSelectionTextField.text = String(_year.year)
                ui_groupSelectionTextField.text = _group.title
                ui_monthSelectionTextField.text = _month.month
                ui_categorySelectionTextField.text = _invoice.categoryObject?.title
                ui_amountTextField.text = String(describing: _invoice.amount)
                
                if _invoice.identifier != nil {
                    // Get URL for existing document
//                  _pickedDocument = SaveManager.getDocumentURL()
//                    _pickedDocument = Bundle.main.url(forResource: "Boulanger.com", withExtension: "pdf")
                    _documentHasBeenAdded = true
                }
                
                ui_addOrModifyButton.setTitle("Modifier", for: .normal)
            }
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
        }
    }
    
    //TODO: Show info if document has been added or hide if not
    private func updateDocumentInfo () {
        if _documentHasBeenAdded == false {
            ui_documentAddedLabel.isHidden = true
            ui_deleteAddedDocumentButton.isHidden = true
            ui_addNewDocumentButton.isHidden = false
        }else {
            ui_documentAddedLabel.isHidden = false
            ui_deleteAddedDocumentButton.isHidden = false
            ui_addNewDocumentButton.isHidden = true
        }
    }

    private func getCategoryName() -> String {
        var categoryName: String = ""
        if let text = ui_categorySelectionTextField.text {
            categoryName = text
        }
        return categoryName
    }
    
    private func deletePreviousDocumentIfRequested (withIdentifier documentId: String, _ request: Bool) {
        if request == true {
            SaveManager.removeDocument(forIdentifier: documentId)
        }
    }
    
    private func animateIn(forSubview subview: UIView) {
        self.view.addSubview(subview)
        let navigationBarHeight: CGFloat = 44
        let topAdjust = navigationBarHeight + 60
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAdjust).isActive = true
        
        subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subview.alpha = 0
        
        ui_visualEffect.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.ui_visualEffect.effect = self._visualEffect
            subview.alpha = 1
            subview.transform = CGAffineTransform.identity
        }
    }
    private func animateOut (forSubview subview: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            
            self.ui_visualEffect.effect = nil
        }) { (success: Bool) in
            subview.removeFromSuperview()
        }
        ui_visualEffect.isHidden = true
    }
    
    
    //MARK: - IBAction functions
    //TODO: Hide the keyboard
    @IBAction func doneKeyboardViewButtonpressed(_ sender: UIButton) {
        _activeTextField.resignFirstResponder()
        if _activeTextField == ui_amountTextField {
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
        }
    }
    
    //TODO: Add a new document to the invoice
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
    
    @IBAction func addNewCategoryButtonPressed(_ sender: UIButton) {
        ui_addNewCategoryTextField.becomeFirstResponder()
        animateIn(forSubview: ui_createCategoryView)
    }
    
    @IBAction func cancelNewCategoryView(_ sender: UIButton) {
        ui_addNewCategoryTextField.resignFirstResponder()
        animateOut(forSubview: ui_createCategoryView)
    }
    
    @IBAction func createNewCategory(_ sender: UIButton) {
        if let newCatgoryName = ui_addNewCategoryTextField.text {
            let createdCategory = _manager.addCategory(newCatgoryName)
            ui_categorySelectionTextField.text = createdCategory.title
        }
        ui_addNewCategoryTextField.resignFirstResponder()
        animateOut(forSubview: ui_createCategoryView)
    }
    
    //TODO: Delete added document from invoice
    @IBAction func deleteAddedDocument(_ sender: UIButton) {
         // Delete the reference to the document
        _pickedDocument = nil
        _documentHasBeenAdded = false
        
        // Specify that we want to delete the previous document on save
        _deletePreviousDocument = true
        
        // update UI
        updateDocumentInfo()
    }
    
    //TODO: Add invoice to collectionView + DB
    @IBAction func addNewInvoiceButtonPressed(_ sender: UIButton) {
        let categoryName = getCategoryName()
        var categoryObject: Category? = nil
        if let description = ui_descriptionTextField.text,
            let monthString = ui_monthSelectionTextField.text,
            let groupName = ui_groupSelectionTextField.text,
            let group = _year.getGroup(forName: groupName),
            let amount = ui_amountTextField,
            let convertedAmount = _manager.convertFromCurrencyNumber(forTextField: amount) {
            
                if categoryName != "" {
                    categoryObject = _manager.getCategory(forName: categoryName)
                }
            
                let amountDouble = Double(truncating: convertedAmount as NSNumber)
                let newMonth = group.checkIfMonthExist(forMonthName: monthString)
            
                if _modifyInvoice == false {
                    SaveManager.saveDocument(documentURL: _pickedDocument, description: description, categoryObject: categoryObject ,amount: amountDouble, newMonth: newMonth)
                }else {
                    if let documentId = _invoice.identifier {
                        deletePreviousDocumentIfRequested(withIdentifier: documentId, _deletePreviousDocument)
                    }
                    SaveManager.saveDocument(documentURL: _pickedDocument, description: description, categoryObject: categoryObject, amount: amountDouble, currentMonth: _month, newMonth: newMonth, invoice: _invoice, modify: true, documentAdded: _documentHasBeenAdded)
                }
                dismiss(animated: true, completion: nil )
        }else {
            print("Something went wrong")
        }
    }

    //TODO: Dismiss view controller
    @IBAction func cancelVCButtonPressed(_ sender: Any) {
        ui_descriptionTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Extensions
//TODO: - textField Delegate
extension AddNewInvoiceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Store textfield clicked
        _activeTextField = textField
        
        // Define actions for each textFields
        if (textField == ui_monthSelectionTextField) {
            monthsPickerView = MonthsPicker()
            ui_monthSelectionTextField.inputView = _pickerView
            _pickerView.delegate = monthsPickerView
            monthsPickerView._monthTextField = ui_monthSelectionTextField
        }
        if (textField == ui_groupSelectionTextField) {
            groupPickerView = GroupPicker()
            ui_groupSelectionTextField.inputView = _pickerView
            _pickerView.delegate = groupPickerView
            groupPickerView._year = _year
            groupPickerView._groupTextField = ui_groupSelectionTextField
            groupPickerView.selectDefaultRow(forGroup: _group, forPickerView: _pickerView)
        }
        if (textField == ui_categorySelectionTextField) {
            categoryPickerView = CategoryPicker()
            ui_categorySelectionTextField.inputView = _pickerView
            _pickerView.delegate = categoryPickerView
            categoryPickerView._manager = _manager
            categoryPickerView._categoryTextField = ui_categorySelectionTextField
            
            if (_manager.getCategoryCount() > 0) {
                // First category title must never be shown in the pickerView
                if let category = _manager.getCategory(atIndex: 1) {
                    ui_categorySelectionTextField.text = category.title
                }else {
                    ui_categorySelectionTextField.text = nil
                }
            }
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
        _documentHasBeenAdded = true
        updateDocumentInfo()
    }
}

extension AddNewInvoiceViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        _pickedDocument = Bundle.main.url(forResource: "Boulanger.com", withExtension: "pdf")
        _documentHasBeenAdded = true
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