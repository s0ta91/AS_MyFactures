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
    @IBOutlet var ui_createCategoryView: UIView!
    @IBOutlet var ui_modifyCategoryView: UIView!
    @IBOutlet weak var ui_manageCategoryTableView: UITableView!
    @IBOutlet weak var ui_manageCategoryVisualView: UIVisualEffectView!
    @IBOutlet weak var ui_createNewCategoryTextField: UITextField!
    @IBOutlet weak var ui_modifyCategoryTextField: UITextField!
    
    
    //TODO: Data reveived from previous VC
    var _ptManager: Manager?
    
    //TODO: Internal variables
    private var _manager: Manager!
    private var _selectedCategoryToModify: Category!
    private var _visualEffect: UIVisualEffect!

    override func viewDidLoad() {
        super.viewDidLoad()
        ui_manageCategoryTableView.dataSource = self
        ui_manageCategoryTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRecievedData()
        ui_manageCategoryVisualView.isHidden = true
        _visualEffect = ui_manageCategoryVisualView.effect
        ui_manageCategoryVisualView.effect = nil
        ui_createCategoryView.layer.cornerRadius = 10
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
    
    private func animateIn(forSubview subview: UIView) {
        self.navigationController!.view.addSubview(subview)
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let topAdjust = navigationBarHeight + 60
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAdjust).isActive = true
        
        subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subview.alpha = 0
        
        ui_manageCategoryVisualView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.ui_manageCategoryVisualView.effect = self._visualEffect
            subview.alpha = 1
            subview.transform = CGAffineTransform.identity
        }
    }
    private func animateOut (forSubview subview: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            subview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subview.alpha = 0
            
            self.ui_manageCategoryVisualView.effect = nil
        }) { (success: Bool) in
            subview.removeFromSuperview()
        }
        ui_manageCategoryVisualView.isHidden = true
    }
    
    @IBAction func cancelManageCategoryVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewCategoryButtonPressed(_ sender: UIBarButtonItem) {
        animateIn(forSubview: ui_createCategoryView)
        ui_createNewCategoryTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelCreateCategoryView(_ sender: UIButton) {
        ui_createNewCategoryTextField.resignFirstResponder()
        ui_modifyCategoryTextField.resignFirstResponder()
        animateOut(forSubview: ui_createCategoryView)
    }
    
    @IBAction func addNewCategory(_ sender: UIButton) {
        if let newCategoryName = ui_createNewCategoryTextField.text {
            _manager.addCategory(newCategoryName)
        }
        ui_createNewCategoryTextField.resignFirstResponder()
        ui_manageCategoryTableView.reloadData()
        animateOut(forSubview: ui_createCategoryView)
    }
    
    @IBAction func modifyCategory(_ sender: Any) {
        if let newCategoryTitle = ui_modifyCategoryTextField.text {
            _manager.modifyCategoryTitle(forCategory: _selectedCategoryToModify, withNewTitle: newCategoryTitle)
            ui_manageCategoryTableView.reloadData()
            animateOut(forSubview: ui_modifyCategoryView)
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
        cell_category.textLabel?.text = _manager.getCategory(atIndex: indexPath.row)?.title
        return cell_category
    }

}

//MARK: - Table view delegate
extension ManageCategoryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Modifier") { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let category = self._manager.getCategory(atIndex: indexPath.row) {
                self._selectedCategoryToModify = category
                self.ui_modifyCategoryTextField.text = category.title
                self.ui_modifyCategoryTextField.becomeFirstResponder()
                self.animateIn(forSubview: self.ui_modifyCategoryView)
            }
        }
        editAction.backgroundColor = UIColor(named: "EditButtonGrey")
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action: UITableViewRowAction, indexPath: IndexPath) in
            self._manager.removeCategory(atIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = .red
        return [editAction, deleteAction]
    }
}

