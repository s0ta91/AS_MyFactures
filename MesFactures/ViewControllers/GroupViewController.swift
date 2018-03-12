//
//  GroupViewController.swift
//  MesFactures
//
//  Created by Sébastien on 05/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    
    //MARK: - GroupViewController
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet var ui_keyboardSearchBarView: UIView!
    @IBOutlet weak var ui_searchBarView: UIView!
    
    @IBOutlet weak var ui_searchBar: UISearchBar!
    @IBOutlet weak var ui_tabBarView: UIView!
    
    @IBOutlet weak var ui_newGroupButton: UIButton!
    @IBOutlet weak var ui_visualEffectView: UIVisualEffectView!
    @IBOutlet var ui_createGroupView: UIView!
    @IBOutlet weak var ui_newGroupNameTextField: UITextField!
    
     @IBOutlet weak var searchBarViewHeight: NSLayoutConstraint!
    
    //MARK: - CreateGroupPopupView
    @IBOutlet weak var ui_groupNameTextField: UITextField!
    @IBOutlet weak var ui_groupIdeaCV: UICollectionView!
    @IBOutlet weak var ui_addGroupButton: UIButton!
    
    
    //MARK: - Variables declaration
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }
    private var _currentYear: Year!
    private var _groupToModify: Group?
    var effect: UIVisualEffect!
    let monthArray = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    var isListFiltered = false
   
    
    
    //MARK: -  ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        groupCV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _currentYear = _manager.getSelectedYear()
        _currentYear.setGroupList()
        groupCV.clipsToBounds = false
        
        ui_visualEffectView.isHidden = true
        effect = ui_visualEffectView.effect
        ui_visualEffectView.effect = nil
        ui_createGroupView.layer.cornerRadius = 10
        
        _manager.setHeaderClippedToBound(groupCV)
        
        groupCV.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: -  Private functions
    private func animateIn() {
        self.navigationController!.view.addSubview(ui_createGroupView)
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.height
        let topAdjust = navigationBarHeight + 60
        
        
        ui_createGroupView.translatesAutoresizingMaskIntoConstraints = false
        ui_createGroupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAdjust).isActive = true
        
        ui_createGroupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        ui_createGroupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        ui_createGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        ui_createGroupView.alpha = 0
        
        ui_visualEffectView.isHidden = false
        
        UIView.animate(withDuration: 0.4) {
            self.ui_visualEffectView.effect = self.effect
            self.ui_createGroupView.alpha = 1
            self.ui_createGroupView.transform = CGAffineTransform.identity
        }
    }
    private func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.ui_createGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.ui_createGroupView.alpha = 0
            
            self.ui_visualEffectView.effect = nil
        }) { (success: Bool) in
            self.ui_createGroupView.removeFromSuperview()
        }
        ui_visualEffectView.isHidden = true
        searchBarSearchButtonClicked(self.ui_searchBar)
    }

    
    //MARK: - Actions
    @IBAction func addNewGroupButtonPressed(_ sender: Any) {
        ui_newGroupNameTextField.text = ""
        ui_addGroupButton.setTitle("Valider", for: .normal)
        ui_newGroupNameTextField.becomeFirstResponder()
        animateIn()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        ui_newGroupNameTextField.resignFirstResponder()
        animateOut()
    }
    
    @IBAction func createNewGroupButtonPressed(_ sender: Any) {
        ui_newGroupNameTextField.resignFirstResponder()
        guard let newGroupName = ui_newGroupNameTextField.text else {return print("textFiled is empty")}
        if let selectedGroup = _groupToModify {
            _currentYear.modifyGroupTitle(forGroup: selectedGroup, withNewTitle: newGroupName)
            _groupToModify = nil
            animateOut()
        }else {
            let groupExists = _currentYear.checkForDuplicate(forGroupName: newGroupName, isListFiltered)
            if groupExists == false {
                if let newGroup = _currentYear.addGroup(withTitle: newGroupName, isListFiltered) {
                    for monthName in monthArray {
                        newGroup.addMonth(monthName)
                    }
                }
                animateOut()
            }else {
                let alertController = UIAlertController(title: "Attention", message: "Un groupe existe déjà avec le nom '\(newGroupName)'!", preferredStyle: .alert)
                let createAction = UIAlertAction(title: "Créer", style: .default, handler: { (_) in
                    if let newGroup = self._currentYear.addGroup(withTitle: newGroupName, self.isListFiltered) {
                        for monthName in self.monthArray {
                            newGroup.addMonth(monthName)
                        }
                    }
                    self.animateOut()
                })
                let cancelCreationAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
                alertController.addAction(createAction)
                alertController.addAction(cancelCreationAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        ui_searchBar.text = ""
        ui_searchBar.becomeFirstResponder()
        searchBarViewHeight.constant = 56
        UIView.animate(withDuration: 0.25) {
            self.ui_searchBarView.layoutIfNeeded()
        }
    }
    
    //MARK: - Prepare for Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModaly_yearSelectionVC" {
            if let destinationVC = segue.destination as? SelectYearViewController {
                destinationVC._manager = _manager
            }
        }
        
        if segue.identifier == "show_invoiceCollectionVC" {
            if let destinationVC = segue.destination as? InvoiceCollectionViewController,
                let selectedGroupIndex = groupCV.indexPathsForSelectedItems?.first,
                let selectedGroup = _currentYear.getGroup(atIndex: selectedGroupIndex.row, isListFiltered) {
                    destinationVC._ptManager = _manager
                    destinationVC._ptCurrentGroup = selectedGroup
                    destinationVC._ptYear = _currentYear
            }
        }
    }

}

extension GroupViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let selectedYear = _manager.getSelectedYear() else {fatalError("Couldn't find any selected year")}
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "group_header", for: indexPath) as! HeaderGroupView
            headerView.setYear(withYear: "\(selectedYear.year)")
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return _currentYear.getGroupCount()
        }else {
            return _manager.getGroupIdeaCount()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell_group = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_group", for: indexPath) as! GroupCollectionViewCell

            if let group = _currentYear.getGroup(atIndex: indexPath.row, isListFiltered) {
                cell_group.setValues(_manager, group)
            }

            cell_group.layer.borderWidth = 1.0
            cell_group.layer.borderColor = UIColor.clear.cgColor
            cell_group.layer.shadowColor = UIColor.lightGray.cgColor
            cell_group.layer.shadowOffset = CGSize(width:2,height: 2)
            cell_group.layer.shadowRadius = 2.0
            cell_group.layer.shadowOpacity = 1.0
            cell_group.layer.masksToBounds = false;
            cell_group.layer.shadowPath = UIBezierPath(rect:cell_group.bounds).cgPath
            
            cell_group.delegate = self
            return cell_group
        }else {
            let cell_groupIdea = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_groupIdea", for: indexPath) as! GroupIdeasCollectionViewCell
            let titleList:[String] = _manager.getGroupIdeaNameList()
            cell_groupIdea.setTitle(titleList[indexPath.row])
            return cell_groupIdea
        }
    }

}

extension GroupViewController: GroupCollectionViewCellDelegate {
    
    func showGroupActions(groupCell: GroupCollectionViewCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let modify = UIAlertAction(title: "Modifier le nom du groupe", style: .default) { (_) in
            if let indexPath = self.groupCV.indexPath(for: groupCell),
                let group = self._currentYear.getGroup(atIndex: indexPath.row, self.isListFiltered) {
                    self.ui_newGroupNameTextField.text = group.title
                    self.ui_addGroupButton.setTitle("Modifier", for: .normal)
                    self.ui_newGroupNameTextField.becomeFirstResponder()
                    self._groupToModify = group
                    self.animateIn()
            }
        }

        let delete = UIAlertAction(title: "Supprimer le groupe", style: .destructive) { (_) in
            let alertDeletion = UIAlertController(title: "Attention", message: "La suppression de ce dossier entrainera la suppression de toutes les factures associées sans possibilité de les récupérer. Souhaitez-vous continuer ?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Supprimer définitivement", style: .destructive, handler: { (_) in
                if let indexPath = self.groupCV.indexPath(for: groupCell),
                    let groupNameToDelete = groupCell.ui_titleLabel.text,
                    let group = self._currentYear.getGroup(forName: groupNameToDelete, self.isListFiltered),
                    let groupIndex = self._currentYear.getGroupIndex(forGroup: group) {
                        self._currentYear.removeGroup(atIndex: groupIndex)
                        self._currentYear.removeGroupinListToShow(atIndex: indexPath.row)
                        self.groupCV.deleteItems(at: [indexPath])
                }
            })
            let cancelDeletion = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
            alertDeletion.addAction(deleteAction)
            alertDeletion.addAction(cancelDeletion)
            self.present(alertDeletion, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        actionSheet.addAction(modify)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }

}

extension GroupViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isListFiltered = true
        searchBar.resignFirstResponder()

        if let searchText = searchBar.text {
            _currentYear.setGroupList(containing: searchText)
        }
        groupCV.reloadData()
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isListFiltered = false
        
        searchBarViewHeight.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.ui_searchBarView.layoutIfNeeded()
        }
        _currentYear.setGroupList()
        groupCV.reloadData()
        
        // resignFirstResponder is executed in the main thread whatever if the action above are completed or not
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

