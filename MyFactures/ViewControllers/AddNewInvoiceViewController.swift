//
//  AddNewInvoiceViewController.swift
//  MesFactures
//
//  Created by Sébastien on 15/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import MobileCoreServices
import IQKeyboardManagerSwift

class AddNewInvoiceViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet var ui_createGroupOrCategoryView: UIView!
    @IBOutlet weak var ui_addNewGroupOrCategoryTextField: UITextField!
    
    
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
    var _fromOtherApp: Bool = false
    var _ptLoginVC: UIViewController?
    var _ptPickedDocument: Any?
    
    //MARK: - Global variable filled with passthrough Managers/objects
    private var _manager: Manager!
    private var _year: Year!
    private var _group: Group!
    private var _month: Month!
    private var _invoice: Invoice!
    private var _loginVC: UIViewController!
    
    //MARK: - Others
    //TODO: PickerView Initializer
    private var yearsPickerView: YearsPicker!
    private var monthsPickerView: MonthsPicker!
    private var groupPickerView: GroupPicker!
    private var categoryPickerView: CategoryPicker!
    
    //TODO: Create PickerView
    private var _pickerView = UIPickerView()

    //TODO: Create variable to hold textField in use
    private var _activeTextField: UITextField!
    
    private var _isNewGroup: Bool = false
    private var _pickedDocument: Any?
    private var _photoFromCamera: Bool = false
    private var _documentHasBeenAdded: Bool = false
    private var _documentExtension: String = ""
    private var _deletePreviousDocument: Bool = false
    private var _firstLoad: Bool = true
    private var _visualEffect: UIVisualEffect!
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_descriptionTextField.delegate = self
        ui_yearSelectionTextField.delegate = self
        ui_monthSelectionTextField.delegate = self
        ui_groupSelectionTextField.delegate = self
        ui_categorySelectionTextField.delegate = self
        ui_addNewGroupOrCategoryTextField.delegate = self
        ui_amountTextField.delegate = self
        ui_amountTextField.autocorrectionType = .no
        ui_createGroupOrCategoryView.layer.cornerRadius = 10
        
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20.0
        
        checkReceivedData()
        setSeparatorForFields()
        setAccessoryViewForPickersView()
        setDefaultValues()
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
        guard let receivedManager = _ptManager else { fatalError("Manager :\(String(describing: _ptManager)) unknown") }
        guard let receivedYear = _ptYear else { fatalError("Year :\(String(describing: _ptYear)) unknown") }
        _manager = receivedManager
        _year = receivedYear
        
        if _fromOtherApp {
            guard let loginVC = _ptLoginVC else { fatalError("LoginVC Unknown") }
            guard let documentFromOtherApp = _ptPickedDocument else { fatalError("No URL received in parameter")  }
            if isGroup(forYear: receivedYear) {
                _group = _year.getGroup(atIndex: 0)
            } else {
                ui_groupSelectionTextField.isEnabled = false
            }
            
            _loginVC = loginVC
            setDocument(withUrl: documentFromOtherApp, documentExtension: "PDF")
        } else {
            guard let receivedGroup = _ptGroup else { fatalError("Group :\(String(describing: _ptGroup)) unknown") }
            _group = receivedGroup
            
            if _modifyInvoice {
                guard let receivedMonth = _ptMonth else { fatalError("Month \(String(describing: _ptMonth)) unknown") }
                guard let receivedInvoice = _ptInvoice else { fatalError("Invoice \(String(describing: _ptInvoice)) unknown")}
                _month = receivedMonth
                _invoice = receivedInvoice
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
        ui_yearSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_monthSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_groupSelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_categorySelectionTextField.inputAccessoryView = ui_keyboardToolbarView
        ui_amountTextField.inputAccessoryView = ui_keyboardToolbarView
    }

    //TODO: Set defaults values for all fields
    private func setDefaultValues () {
        if _firstLoad == true {
            _firstLoad = false
//            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
            ui_addOrModifyButton.layer.cornerRadius = 10
            let groupTitle = isGroup(forYear: _year) ? _group.title : "Aucun dossier disponible"
            
            if _modifyInvoice == false {
                ui_descriptionTextField.becomeFirstResponder()
                ui_monthSelectionTextField.text = Date().currentMonth
                ui_yearSelectionTextField.text = String(_year.year)
                ui_groupSelectionTextField.text = groupTitle
                ui_categorySelectionTextField.text = "Non-classée"
            } else {
                ui_descriptionTextField.text = _invoice.detailedDescription
                ui_yearSelectionTextField.text = String(_year.year)
                ui_groupSelectionTextField.text = groupTitle
                ui_monthSelectionTextField.text = _month.month
                ui_categorySelectionTextField.text = _invoice.categoryObject?.title
                ui_amountTextField.text = String(describing: _invoice.amount)
                
                if _invoice.identifier != nil {
                    _documentHasBeenAdded = true
                }
                ui_addOrModifyButton.setTitle("Modifier", for: .normal)
            }
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
            
            // Set the background color of evry uiPickerVIew to white
            _pickerView.backgroundColor = .white
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
    
    private func deletePreviousDocumentIfRequested (withIdentifier documentId: String, andExtension documentExtension: String, _ request: Bool) {
        if request == true {
            SaveManager.removeDocument(forIdentifier: documentId, andExtension: documentExtension)
        }
    }
    
    private func setDocument(withUrl url: Any?, documentExtension: String) {
        _pickedDocument = url
        _documentExtension = documentExtension
        _documentHasBeenAdded = true
        updateDocumentInfo()
    }
    
    private func animateIn(forSubview subview: UIView) {
        ui_visualEffect.isHidden = false
        self.view.addSubview(subview)

        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subview.alpha = 0
        
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

    private func isGroup(forYear year: Year) -> Bool {
        if year.getGlobalGroupCount() != 0 {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - IBAction functions
    //TODO: Hide the keyboard
    @IBAction func doneKeyboardViewButtonpressed(_ sender: UIButton) {
        _activeTextField.resignFirstResponder()
        if _activeTextField == ui_amountTextField {
            if ui_amountTextField.text == "" {
                ui_amountTextField.text = "0"
            }
            _manager.convertToCurrencyNumber(forTextField: ui_amountTextField)
        }
        
        if _activeTextField == ui_yearSelectionTextField {
            guard let selectedYear = ui_yearSelectionTextField.text,
                let newSelectedYear = _manager.getYear(forValue: Int(selectedYear)!) else { fatalError("No year selected in the years field")}
            _year = newSelectedYear
            ui_groupSelectionTextField.text = isGroup(forYear: newSelectedYear) ? newSelectedYear.getGroup(atIndex: 0)?.title : "Aucun dossier disponible"
            ui_groupSelectionTextField.isEnabled = isGroup(forYear: newSelectedYear) ? true : false
        }
    }
    
    //TODO: - Add a new document to the invoice
    @IBAction func addNewDocumentButtonPressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        //TODO: DocumentPickerViewController to selected a document
        let pdf                                 = String(kUTTypePDF)
//        let spreadsheet                         = String(kUTTypeSpreadsheet)
//        let movie                               = String(kUTTypeMovie)
//        let aviMovie                            = String(kUTTypeAVIMovie)
//        let docs                                = String(kUTTypeCompositeContent)
        let img                                 = String(kUTTypeImage)
        let png                                 = String(kUTTypePNG)
        let jpeg                                = String(kUTTypeJPEG)
//        let txt                                 = String(kUTTypeText)
//        let zip                                 = String(kUTTypeZipArchive)
//        let msg1                                = String(kUTTypeEmailMessage)
//        let msg2                                = String(kUTTypeMessage)
        let allowedDocumentsTypes = [pdf,img,jpeg,png]
        
        let pickADocument = UIAlertAction(title: "Choisir un document", style: .default) { (_) in
            let documentPicker = UIDocumentPickerViewController(documentTypes:  allowedDocumentsTypes, in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        }
        
        //TODO: ImagePickerController to selected a photo in photoLibrary
        let pickAPhoto = UIAlertAction(title: "Choisir une photo", style: .default) { (_) in
            
            self._photoFromCamera = false
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        //TODO: Open photoApp to take a photo of a document
        let takeAPhoto = UIAlertAction(title: "Prendre une photo", style: .default) { (_) in
            
            self._photoFromCamera = true
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                print("Camera not available")
            }
        }
        
        let cancelActionSheet = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        
        actionSheet.addAction(pickADocument)
        actionSheet.addAction(pickAPhoto)
        actionSheet.addAction(takeAPhoto)
        actionSheet.addAction(cancelActionSheet)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: sender.frame.midX, y: sender.frame.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func addNewGroupButtonPressed(_ sender: UIButton) {
        _isNewGroup = true
        ui_addNewGroupOrCategoryTextField.text = ""
        ui_addNewGroupOrCategoryTextField.becomeFirstResponder()
        animateIn(forSubview: ui_createGroupOrCategoryView)
    }
    
    @IBAction func addNewCategoryButtonPressed(_ sender: UIButton) {
        _isNewGroup = false
        ui_addNewGroupOrCategoryTextField.text = ""
        ui_addNewGroupOrCategoryTextField.becomeFirstResponder()
        animateIn(forSubview: ui_createGroupOrCategoryView)
    }
    
    @IBAction func cancelNewCategoryView(_ sender: UIButton) {
        ui_addNewGroupOrCategoryTextField.resignFirstResponder()
        animateOut(forSubview: ui_createGroupOrCategoryView)
    }
    
    @IBAction func createNewGroupOrCategory(_ sender: UIButton) {
        if let textFieldValue = ui_addNewGroupOrCategoryTextField.text {
            if _isNewGroup {
                if !_year.groupExist(forGroupName: textFieldValue) {
                    ui_groupSelectionTextField.text = _year.addGroup(withTitle: textFieldValue, false)?.title
                    ui_groupSelectionTextField.isEnabled = true
                    ui_addNewGroupOrCategoryTextField.resignFirstResponder()
                    animateOut(forSubview: ui_createGroupOrCategoryView)
                } else {
                    Alert.message(title: "Attention", message: "Un group existe déjà avec le nom '\(textFieldValue)'", vc: self)
                }
            } else {
                let categoryExists = _manager.checkForDuplicateCategory(forCategoryName: textFieldValue)
                if categoryExists == false {
                    let createdCategory = _manager.addCategory(textFieldValue)
                    ui_categorySelectionTextField.text = createdCategory.title
                    ui_addNewGroupOrCategoryTextField.resignFirstResponder()
                    animateOut(forSubview: ui_createGroupOrCategoryView)
                }else {
                    Alert.message(title: "Attention", message: "Une catégorie existe déjà avec le nom '\(textFieldValue)'", vc: self)
                }
            }
        }
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
                    SaveManager.saveDocument(document: _pickedDocument, description: description, categoryObject: categoryObject ,amount: amountDouble, newMonth: newMonth, documentType: _documentExtension)
                }else {
                    var _extension = _documentExtension
                    if let documentId = _invoice.identifier,
                        let invoiceDocumentExtension = _invoice.documentType {
                        _extension = invoiceDocumentExtension
                        deletePreviousDocumentIfRequested(withIdentifier: documentId, andExtension: invoiceDocumentExtension ,_deletePreviousDocument)
                    }
                    SaveManager.saveDocument(document: _pickedDocument, description: description, categoryObject: categoryObject, amount: amountDouble, currentMonth: _month, newMonth: newMonth, invoice: _invoice, modify: true, documentAdded: _documentHasBeenAdded, documentType: _extension)
                    
                }
            
                if self._fromOtherApp {
                    self.modalTransitionStyle = .coverVertical
                    self.dismiss(animated: true) {
                        self._loginVC.modalTransitionStyle = .crossDissolve
                        self._loginVC.dismiss(animated: true, completion: nil)
                    }
                } else {
                    dismiss(animated: true, completion: nil)
            }
            
        } else {
            if ui_groupSelectionTextField.text == "Aucun dossier disponible" {
                Alert.message(title: "Erreur", message: "Veuillez créer un dossier", vc: self)
            } else {
                Alert.message(title: "Erreur", message: "Problème avec l'un des champs", vc: self)
                print("Something went wrong with one of the fields")
            }
        }
    }

    //TODO: Dismiss view controller
    @IBAction func cancelVCButtonPressed(_ sender: Any) {
        ui_descriptionTextField.resignFirstResponder()
        dismiss(animated: true, completion: {
            if self._fromOtherApp {
                self._loginVC.modalTransitionStyle = .crossDissolve
                self._loginVC.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}

//MARK: - Extensions
//TODO: - textField Delegate
extension AddNewInvoiceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Store textfield clicked
        _activeTextField = textField

        // Define actions for each textFields
        if (textField == ui_yearSelectionTextField) {
            yearsPickerView = YearsPicker()
            ui_yearSelectionTextField.inputView = _pickerView
            _pickerView.delegate = yearsPickerView
            yearsPickerView._yearTextField = ui_yearSelectionTextField
            yearsPickerView.selectDefaultRow(forYearName: ui_yearSelectionTextField.text!, forPickerView: _pickerView)
        }
        
        if (textField == ui_monthSelectionTextField) {
            guard let monthName = ui_monthSelectionTextField.text else { fatalError("MonthName is nill")}
            monthsPickerView = MonthsPicker()
            ui_monthSelectionTextField.inputView = _pickerView
            _pickerView.delegate = monthsPickerView
            monthsPickerView._monthTextField = ui_monthSelectionTextField
            monthsPickerView._group = _group
            monthsPickerView.selectDefaultRow(forMonthName: monthName, forPickerView: _pickerView)
        }
        
        if (textField == ui_groupSelectionTextField && isGroup(forYear: _year)) {
            groupPickerView = GroupPicker()
            ui_groupSelectionTextField.inputView = _pickerView
            _pickerView.delegate = groupPickerView
            groupPickerView._year = _year
            groupPickerView._groupTextField = ui_groupSelectionTextField
            groupPickerView.selectDefaultRow(forGroupName: ui_groupSelectionTextField.text!, forPickerView: _pickerView)
        }
        
        if (textField == ui_categorySelectionTextField) {
            categoryPickerView = CategoryPicker()
            ui_categorySelectionTextField.inputView = _pickerView
            _pickerView.delegate = categoryPickerView
            categoryPickerView._manager = _manager
            categoryPickerView._categoryTextField = ui_categorySelectionTextField
            categoryPickerView.selectDefaultRow(forCategoryName: ui_categorySelectionTextField.text!, forPickerView: _pickerView)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_descriptionTextField.resignFirstResponder()
        ui_createGroupOrCategoryView.endEditing(false)
        return true
    }
}

extension AddNewInvoiceViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        _pickedDocument = urls.first
        guard let document = _pickedDocument else {fatalError("No document found")}
        if String(describing: document).hasSuffix("pdf") {
            _documentExtension = "PDF"
            _documentHasBeenAdded = true
        }
        if String(describing: document).hasSuffix("jpeg") {
            _documentExtension = "JPEG"
            _documentHasBeenAdded = true
        }
        if String(describing: document).hasSuffix("jpg") {
            _documentExtension = "JPG"
            _documentHasBeenAdded = true
        }
        if  String(describing: document).hasSuffix("img"){
            _documentExtension = "IMG"
            _documentHasBeenAdded = true
        }
        if  String(describing: document).hasSuffix("png"){
            _documentExtension = "PNG"
            _documentHasBeenAdded = true
        }
        
        updateDocumentInfo()
    }
}

extension AddNewInvoiceViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if _photoFromCamera == false {
            _pickedDocument = info.first?.value as? URL
        }else {
            _pickedDocument = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        _documentExtension = "JPG"
        picker.dismiss(animated: true, completion: nil)
        _documentHasBeenAdded = true
        updateDocumentInfo()
    }
}

extension AddNewInvoiceViewController: UINavigationControllerDelegate {}

//TODO: textField extension limited to this file
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
