//
//  ManageCategoryTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 21/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class ManageCategoryTableViewController: UIViewController {
    
    //MARK: - Declarations
    //TODO: Outlets
    @IBOutlet var ui_modifyCategoryView: UIView!
    @IBOutlet weak var ui_manageCategoryTableView: UITableView!
    @IBOutlet weak var ui_modifyCategoryTextField: UITextField!
    @IBOutlet weak var ui_addNewCategoryButton: UIButton!
    
    let blackView = UIView()
    let addFloatingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let plusImage = UIImage(named: "plus_button_white")
        button.setImage(plusImage, for: .normal)
//        button.backgroundColor = UIColor(named: "navBarTint")
        button.backgroundColor = .black
        button.setFloatingButton()
        button.addTarget(self, action: #selector(addNewCategoryButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //TODO: Data reveived from previous VC
    var _ptManager: Manager?
    
    //TODO: Internal variables
    private var _manager: Manager!
    private var _selectedCategoryToModify: Category!
    private var _visualEffect: UIVisualEffect!
    let BUTTON_SIZE: CGFloat = 56
    
    //TODO: Localized text
    let addNewCategoryButtonAddText = NSLocalizedString("Add", comment: "")
    let addNewCategoryButtonConfirmText = NSLocalizedString("Confirm", comment: "")
    let modifyCategoryWarningTitle = NSLocalizedString("Warning", comment: "")
    let modifyCategoryWarningMessage = NSLocalizedString("This category already exists", comment: "")
    let editRowActionTitle = NSLocalizedString("Edit", comment: "")
    let deleteRowActionTitle = NSLocalizedString("Delete", comment: "")
    let deleteCategoryAlertTitle = NSLocalizedString("Would you like to delete this category ?", comment: "")
    let deleteCategoryAlertMessage = NSLocalizedString("Associated documents will not be deleted", comment: "")
    let cancelActionTitle = NSLocalizedString("Cancel", comment: "")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ui_modifyCategoryTextField.delegate = self
        ui_manageCategoryTableView.dataSource = self
        ui_manageCategoryTableView.delegate = self
        setupFloatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRecievedData()
        ui_modifyCategoryView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Private functions
    private func checkRecievedData() {
        if let recievedManager = _ptManager {
            _manager = recievedManager
        }
    }
    
    /** add floating button */
    private func setupFloatingButton() {
        view.addSubview(addFloatingButton)
        addFloatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addFloatingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        addFloatingButton.heightAnchor.constraint(equalToConstant: BUTTON_SIZE ).isActive = true
        addFloatingButton.widthAnchor.constraint(equalToConstant: BUTTON_SIZE).isActive = true
        addFloatingButton.layer.cornerRadius = BUTTON_SIZE / 2
    }
    
    private func animateIn(forSubview subview: UIView) {
        view.addSubview(blackView)
        view.addSubview(subview)
        
        blackView.backgroundColor = .black
        blackView.frame = view.frame
        blackView.alpha = 0
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subview.alpha = 0
        
        
        UIView.animate(withDuration: 0.4) {
            self.blackView.alpha = 0.4
            subview.alpha = 1
            subview.transform = CGAffineTransform.identity
        }
    }
    private func animateOut (forSubview subview: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            self.blackView.alpha = 0
            
        }) { (success: Bool) in
            self.blackView.removeFromSuperview()
            subview.removeFromSuperview()
        }
    }
    
    
    //MARK: - Actions
    @IBAction func cancelManageCategoryVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addNewCategoryButtonPressed() {
        animateIn(forSubview: ui_modifyCategoryView)
        ui_modifyCategoryTextField.text = ""
        ui_modifyCategoryTextField.becomeFirstResponder()
        ui_addNewCategoryButton.setTitle(addNewCategoryButtonAddText, for: .normal)
    }
    
    @IBAction func cancelCreateCategoryView(_ sender: UIButton) {
        ui_modifyCategoryTextField.resignFirstResponder()
        animateOut(forSubview: ui_modifyCategoryView)
    }
    
    @IBAction func modifyCategory(_ sender: Any) {
        guard let newCategoryName = ui_modifyCategoryTextField.text else {return print("textField is empty")}
        let categoryExists = _manager.checkForDuplicateCategory(forCategoryName: newCategoryName)
        if categoryExists == false {
            if ui_addNewCategoryButton.titleLabel?.text == addNewCategoryButtonAddText {
                _ = _manager.addCategory(newCategoryName)
            }
            else if ui_addNewCategoryButton.titleLabel?.text == addNewCategoryButtonConfirmText {
                _manager.modifyCategoryTitle(forCategory: _selectedCategoryToModify, withNewTitle: newCategoryName)
            }
            ui_manageCategoryTableView.reloadData()
            animateOut(forSubview: ui_modifyCategoryView)
        }else {
            let alertController = UIAlertController(title: modifyCategoryWarningTitle, message: modifyCategoryWarningMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Table view data source
extension ManageCategoryTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return _manager.getCategoryCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_category = tableView.dequeueReusableCell(withIdentifier: "cell_category", for: indexPath)
        if let category = _manager.getCategory(atIndex: indexPath.row) {
            cell_category.textLabel?.text = category.title
            if category.selected == true {
                cell_category.accessoryType = .checkmark
            }else {
                cell_category.accessoryType = .none
            }
        }
        return cell_category
    }

}

//MARK: - Table view delegate
extension ManageCategoryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: editRowActionTitle) { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let category = self._manager.getCategory(atIndex: indexPath.row) {
                self._selectedCategoryToModify = category
                self.ui_modifyCategoryTextField.text = category.title
                self.ui_modifyCategoryTextField.becomeFirstResponder()
                self.ui_addNewCategoryButton.setTitle(self.addNewCategoryButtonConfirmText, for: .normal)
                self.animateIn(forSubview: self.ui_modifyCategoryView)
            }
        }
        editAction.backgroundColor = UIColor(named: "EditButtonGrey")
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: deleteRowActionTitle) { (action: UITableViewRowAction, indexPath: IndexPath) in
            let alert = UIAlertController(title: self.deleteCategoryAlertTitle, message: self.deleteCategoryAlertMessage, preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: self.deleteRowActionTitle, style: .destructive) { (_) in
                self._manager.removeCategory(atIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let cancelAction = UIAlertAction(title: self.cancelActionTitle, style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = .red
        return [editAction, deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategory = _manager.getCategory(atIndex: indexPath.row) {
            _manager.setSelectedCategory(forCategory: selectedCategory)
            tableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
    }

}

extension ManageCategoryTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_modifyCategoryView.endEditing(false)
        return true
    }
}

