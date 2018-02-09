//
//  ManageGroupTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 08/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class ManageGroupTableViewController: UIViewController {
    
    var _manager: Manager!
    private var _visualEffect: UIVisualEffect!
    private var _selectedGroup: Group!
    
    @IBOutlet weak var ui_manageGroupTableView: UITableView!
    @IBOutlet weak var ui_manageGroupVisualEffectView: UIVisualEffectView!
    @IBOutlet var ui_modifyGroupView: UIView!
    @IBOutlet weak var ui_modifiedGroupNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_manageGroupTableView.dataSource = self
        ui_manageGroupTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ui_manageGroupVisualEffectView.isHidden = true
        _visualEffect = ui_manageGroupVisualEffectView.effect
        ui_manageGroupVisualEffectView.effect = nil
        ui_modifyGroupView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func animateIn() {
        self.navigationController!.view.addSubview(ui_modifyGroupView)
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let topAdjust = navigationBarHeight + 60
        
        
        ui_modifyGroupView.translatesAutoresizingMaskIntoConstraints = false
        ui_modifyGroupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAdjust).isActive = true
        
        ui_modifyGroupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        ui_modifyGroupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        ui_modifyGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        ui_modifyGroupView.alpha = 0
        
        ui_manageGroupVisualEffectView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.ui_manageGroupVisualEffectView.effect = self._visualEffect
            self.ui_modifyGroupView.alpha = 1
            self.ui_modifyGroupView.transform = CGAffineTransform.identity
        }
    }
    private func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.ui_modifyGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.ui_modifyGroupView.alpha = 0
            
            self.ui_manageGroupVisualEffectView.effect = nil
        }) { (success: Bool) in
            self.ui_modifyGroupView.removeFromSuperview()
        }
        ui_manageGroupVisualEffectView.isHidden = true
    }
    
    @IBAction func closeVCButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func modifyGroupNameButtonPressed(_ sender: Any) {
        if let newTitle = ui_modifiedGroupNameTextField.text {
            _manager.modifyGroupTitle(forGroup: _selectedGroup, withNewTitle: newTitle)
            ui_manageGroupTableView.reloadData()
            animateOut()
        }
    }
    
    @IBAction func cancelModifyGroupNameButtonPressed(_ sender: Any) {
        animateOut()
    }

}

extension ManageGroupTableViewController: UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _manager.getGroupCount()
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_groupManage = tableView.dequeueReusableCell(withIdentifier: "cell_manageGroup", for: indexPath)
        if let group = _manager.getGroup(atIndex: indexPath.row) {
            cell_groupManage.textLabel?.text = group.title
        }
        return cell_groupManage
    }
}

extension ManageGroupTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Modifier") { (action: UITableViewRowAction, indexPath: IndexPath) in
            if let group = self._manager.getGroup(atIndex: indexPath.row) {
                self._selectedGroup = group
                self.ui_modifiedGroupNameTextField.text = group.title
                self.animateIn()
            }
        }
        editAction.backgroundColor = UIColor(named: "EditButtonGrey")
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action: UITableViewRowAction, indexPath: IndexPath) in
            self._manager.removeGroup(atIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction, editAction]
    }
}
