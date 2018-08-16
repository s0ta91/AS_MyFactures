//
//  GroupViewController.swift
//  MesFactures
//
//  Created by Sébastien on 05/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import IQKeyboardManagerSwift
import StoreKit

class GroupViewController: UIViewController {
    
    //MARK: - GroupViewController
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet weak var ui_searchBarView: UIView!
    
    @IBOutlet weak var ui_searchBar: UISearchBar!
    @IBOutlet weak var ui_tabBarView: UIView!
    
    @IBOutlet weak var ui_newGroupButton: UIButton!
    @IBOutlet weak var ui_visualEffectView: UIVisualEffectView!
    @IBOutlet var ui_createGroupView: UIView!
    @IBOutlet weak var ui_newGroupNameTextField: UITextField!
    
    @IBOutlet weak var searchBarViewHeight: NSLayoutConstraint!

    
    //MARK: - Properties
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
    let monthArray = [NSLocalizedString("January", comment: ""),
                      NSLocalizedString("February", comment: ""),
                      NSLocalizedString("March", comment: ""),
                      NSLocalizedString("April", comment: ""),
                      NSLocalizedString("May", comment: ""),
                      NSLocalizedString("June", comment: ""),
                      NSLocalizedString("July", comment: ""),
                      NSLocalizedString("August", comment: ""),
                      NSLocalizedString("September", comment: ""),
                      NSLocalizedString("October", comment: ""),
                      NSLocalizedString("November", comment: ""),
                      NSLocalizedString("December", comment: "")]
    var isListFiltered = false
    var collectionViewFontSize: CGFloat!
    
    //TODO: Localized text
    let createNewFolderWarningTitle = NSLocalizedString("Warning", comment: "")
    let createNewFolderWarningMessage = NSLocalizedString("This folder already exists", comment: "")
    let createAddActionTitle = NSLocalizedString("Add", comment: "")
    let cancelActionTitle = NSLocalizedString("Cancel", comment: "")
    let deleteActionTitle = NSLocalizedString("Delete", comment: "")
    let descriptionStr = NSLocalizedString("Tap the 'New folder' icon bellow to begin", comment: "")
    let editFolderActionTitle = NSLocalizedString("Edit folder name", comment: "")
    let deleteFolderActionTitle = NSLocalizedString("Delete folder", comment: "")
    let deleteFolderActionMessage = NSLocalizedString("Deletion of this folder will errase all associated documents definitively.", comment: "")
    
    
    //MARK: -  ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReviewController()
        
        if Manager.isFirstLoad() {
            Manager.presentLoginScreen(fromViewController: self)
            Manager.setIsFirstLoad(false)
        }
        
        ui_newGroupNameTextField.delegate = self
        IQKeyboardManager.shared.enableAutoToolbar = false
        groupCV.dataSource = self
        groupCV.delegate = self
        
        groupCV.emptyDataSetSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _currentYear = _manager.getSelectedYear()
        _currentYear.setGroupList()
        setFontSize()
        
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
    private func setupReviewController() {
        SKStoreReviewController.requestReview()
    }
    
    private func animateIn() {
        ui_visualEffectView.isHidden = false
        self.navigationController!.view.addSubview(ui_createGroupView)

        
        ui_createGroupView.translatesAutoresizingMaskIntoConstraints = false
        ui_createGroupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        ui_createGroupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: +10).isActive = true
        ui_createGroupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        
        
        ui_createGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        ui_createGroupView.alpha = 0
        
        
        
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
    private func setFontSize (){
        let collectionViewWidth = groupCV.frame.size.width
        if collectionViewWidth == 288 {
            collectionViewFontSize = 15
        }else if collectionViewWidth >= 343 {
            collectionViewFontSize = 17
        }
    }
    
    //MARK: - Actions
    @IBAction func addNewGroupButtonPressed(_ sender: Any) {
        ui_newGroupNameTextField.text = ""
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
                _ = _currentYear.addGroup(withTitle: newGroupName, isListFiltered)
                animateOut()
            }else {
                let alertController = UIAlertController(title: createNewFolderWarningTitle, message: createNewFolderWarningMessage, preferredStyle: .alert)
                let createAction = UIAlertAction(title: createAddActionTitle, style: .default, handler: { (_) in
                    if let newGroup = self._currentYear.addGroup(withTitle: newGroupName, self.isListFiltered) {
                        for monthName in self.monthArray {
                            newGroup.addMonth(monthName)
                        }
                    }
                    self.animateOut()
                })
                let cancelCreationAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
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
        
        // FIXME: Bug here when swipe on groupCell to the right in the cell. selectedGroup is nil so the App crash
        if segue.identifier == "show_invoiceCollectionVC" {
            if let destinationVC = segue.destination as? InvoiceCollectionViewController,
                let selectedGroupIndex = groupCV.indexPathsForSelectedItems?.first,
                let selectedGroup = _currentYear.getGroup(atIndex: selectedGroupIndex.row, isListFiltered) {
                    destinationVC._ptManager = _manager
                    destinationVC._ptCurrentGroup = selectedGroup
                    destinationVC._ptYear = _currentYear
                    destinationVC._ptFontSize = collectionViewFontSize
            }else {
                fatalError("One of these variable is nil (destinationVC / selectedGroupindex / selectedGroup)")
            }
        }
    }

}

extension GroupViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headerView: HeaderGroupView!
        guard let selectedYear = _manager.getSelectedYear() else {fatalError("Couldn't find any selected year")}
        switch kind {
        case UICollectionElementKindSectionHeader:
           headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "group_header", for: indexPath) as!  HeaderGroupView
           headerView.setYear(withYear: "\(selectedYear.year)", fontSize: collectionViewFontSize)
        default:
            assert(false, "Unexpected element kind")
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _currentYear.getGroupCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell_group = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_group", for: indexPath) as! GroupCollectionViewCell

        if let group = _currentYear.getGroup(atIndex: indexPath.row, isListFiltered) {
            cell_group.setValues(group, fontSize: collectionViewFontSize)
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
    }
}

extension GroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = groupCV.frame.size.width
        return CGSize(width: width, height: 115)
    }
}

extension GroupViewController: GroupCollectionViewCellDelegate {
    
    func showGroupActions(groupCell: GroupCollectionViewCell, buttonPressed: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let modify = UIAlertAction(title: editFolderActionTitle, style: .default) { (_) in
            if let indexPath = self.groupCV.indexPath(for: groupCell),
                let group = self._currentYear.getGroup(atIndex: indexPath.row, self.isListFiltered) {
                    self.ui_newGroupNameTextField.text = group.title
                    self.ui_newGroupNameTextField.becomeFirstResponder()
                    self._groupToModify = group
                    self.animateIn()
            }
        }

        let delete = UIAlertAction(title: deleteFolderActionTitle, style: .destructive) { (_) in
            let alertDeletion = UIAlertController(title: self.createNewFolderWarningTitle, message: self.deleteFolderActionMessage, preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: self.deleteActionTitle, style: .destructive, handler: { (_) in
                if let indexPath = self.groupCV.indexPath(for: groupCell),
                    let groupNameToDelete = groupCell.ui_titleLabel.text,
                    let group = self._currentYear.getGroup(forName: groupNameToDelete, self.isListFiltered),
                    let groupIndex = self._currentYear.getGroupIndex(forGroup: group) {
                        self._currentYear.removeGroup(atIndex: groupIndex)
                        self._currentYear.removeGroupinListToShow(atIndex: indexPath.row)
                        self.groupCV.deleteItems(at: [indexPath])
                        self.groupCV.reloadData()
                }
            })
            let cancelDeletion = UIAlertAction(title: self.cancelActionTitle, style: .cancel, handler: nil)
            alertDeletion.addAction(deleteAction)
            alertDeletion.addAction(cancelDeletion)
            self.present(alertDeletion, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        actionSheet.addAction(modify)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = groupCell.contentView
            popoverController.sourceRect = CGRect(x: buttonPressed.frame.midX , y: buttonPressed.frame.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
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

extension GroupViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "folderCollectionViewBackground_128")
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = descriptionStr
        let attr = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attr)
    }
}

extension GroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ui_createGroupView.endEditing(false)
        return true
    }
}

