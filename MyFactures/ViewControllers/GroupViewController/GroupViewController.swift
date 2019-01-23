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
import Buglife

class GroupViewController: UIViewController {
    //MARK: - GroupViewController
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet weak var ui_searchBarView: UIView!
    
    @IBOutlet weak var ui_searchBar: UISearchBar!
    @IBOutlet weak var ui_tabBarView: UIView!
    
    @IBOutlet weak var ui_newGroupButton: UIButton!
    @IBOutlet var ui_createGroupView: UIView!
    @IBOutlet weak var ui_newGroupNameTextField: UITextField!
    
    @IBOutlet weak var searchBarViewHeight: NSLayoutConstraint!

    var yearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow_24"), for: .normal)
        button.setTitle("2019", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: button.imageEdgeInsets.top, left: 0, bottom: button.imageEdgeInsets.bottom, right: button.imageEdgeInsets.right)
        button.titleEdgeInsets = UIEdgeInsets(top: button.titleEdgeInsets.top, left: button.imageEdgeInsets.right, bottom: button.titleEdgeInsets.bottom, right: 0)
        return button
    }()
    var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    let addFloatingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let plusImage = UIImage(named: "plus_button_white")
        button.setImage(plusImage, for: .normal)
        button.backgroundColor = UIColor(named: "navBarTint")
        button.setFloatingButton()
        button.addTarget(self, action: #selector(addNewGroupButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    let yearBarButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Bold", size: 16)
        button.setImage(UIImage(named: "left_arrow_black"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        return button
    }()
    let BUTTON_SIZE: CGFloat = 56
    var sideYearIsShown = false
    var blackViewAlphaValue: CGFloat = 0
    
    //MARK: - Properties
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }
    
    lazy var _settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher._homeController = self
        return launcher
    }()
    
    private var _currentYear: Year!
    private var _groupToModify: Group?
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
    var newSideAnchorConstant: CGFloat?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDissmiss), name: NSNotification.Name("refreshCollectionViewWithSelectedYear"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sideYearAnchorIsChanging(_:)), name: NSNotification.Name("sideAnchorIsChanging"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sideYearAnchorChangeHasBegan), name: NSNotification.Name("sideAnchorChangeHasBegan"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sideYearAnchorChangeEnded(_:)), name: NSNotification.Name("sideAnchorChangeEnded"), object: nil)
        
        if Manager.isFirstLoad() {
            Manager.presentLoginScreen(fromViewController: self)
            Manager.setIsFirstLoad(false)
        }
        ui_newGroupNameTextField.delegate = self
        IQKeyboardManager.shared.enableAutoToolbar = false
        groupCV.dataSource = self
        groupCV.delegate = self
        groupCV.emptyDataSetSource = self
        
        setupYearBarItemButton()
        setupFloatingButton()
        
    }
    
    private func setupYearBarItemButton() {
       upadateYearBarItemButtonTitle()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: yearBarButton)
        yearBarButton.addTarget(self, action: #selector(showYearSelector), for: .touchUpInside)
    }
    
    private func upadateYearBarItemButtonTitle() {
        guard let selectedYear = _manager.getSelectedYear() else {fatalError("Couldn't find any selected year")}
        yearBarButton.setTitle("\(selectedYear.year)", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupGroupList()
        setFontSize()
        ui_createGroupView.layer.cornerRadius = 10
        
        _manager.setHeaderClippedToBound(groupCV)
        
        groupCV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Public functions
    func showController(forSetting setting: Setting) {
        
        switch setting.name {
        case .feedback:
            let appearance = Buglife.shared().appearance
            appearance.barTintColor = UIColor(named: "navBarTint")
            appearance.tintColor = .white
            Buglife.shared().presentReporter()
        case .informations:
            let storyboard = UIStoryboard(name: "UserInfosViewController", bundle: Bundle.main)
            let UserInfosVC = storyboard.instantiateViewController(withIdentifier: "UserInfosVC") as! UserInfosViewController
            self.show(UserInfosVC, sender: nil)
        case .resetPassword:
            let storyboard = UIStoryboard(name: "ResetPasswordViewController", bundle: Bundle.main)
            let ResetPasswordVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordViewController
            self.show(ResetPasswordVC, sender: nil)
        case .about:
            let storyboard = UIStoryboard(name: "AboutViewController", bundle: Bundle.main)
            let AboutVC = storyboard.instantiateViewController(withIdentifier: "AboutVC") as! AboutViewController
            self.show(AboutVC, sender: nil)
        case .cancel:
            break
        }
    }
    
    
    //MARK: -  Private functions
    private func setupFloatingButton() {
        view.addSubview(addFloatingButton)
        addFloatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addFloatingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        addFloatingButton.heightAnchor.constraint(equalToConstant: BUTTON_SIZE ).isActive = true
        addFloatingButton.widthAnchor.constraint(equalToConstant: BUTTON_SIZE).isActive = true
        addFloatingButton.layer.cornerRadius = BUTTON_SIZE / 2
    }
    
    private func setupBlackView() {
        if let window = UIApplication.shared.keyWindow {
            blackView.frame = window.frame
            window.addSubview(blackView)
        }
    }
    
    private func setupGroupList() {
        self._currentYear = self._manager.getSelectedYear()
        self._currentYear.setGroupList()
    }
    
    
    private func animateIn() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(ui_createGroupView)
            ui_createGroupView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
            
            ui_createGroupView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: +10).isActive = true
            ui_createGroupView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -10).isActive = true
        }
        ui_createGroupView.translatesAutoresizingMaskIntoConstraints = false
        ui_createGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        ui_createGroupView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.blackView.alpha = 0.5
            self.ui_createGroupView.alpha = 1
            self.ui_createGroupView.transform = CGAffineTransform.identity
        }
    }
    private func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.ui_createGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.blackView.alpha = 0
            self.ui_createGroupView.alpha = 0
        }) { (success: Bool) in
            self.ui_createGroupView.removeFromSuperview()
            self.blackView.removeFromSuperview()
        }
        searchBarSearchButtonClicked(self.ui_searchBar)
    }
    private func setFontSize (){
        print("gcv size [\(groupCV.frame.size.width)]")
        let collectionViewWidth = groupCV.frame.size.width
        if collectionViewWidth == 288 {
            collectionViewFontSize = 15
        }else if collectionViewWidth >= 343 {
            collectionViewFontSize = 17
        }
    }

    @objc func handleDissmiss() {
        setupGroupList()
        self.upadateYearBarItemButtonTitle()
        NotificationCenter.default.post(name: NSNotification.Name("showHideSideYearSelector"), object: nil)
        UIView.animate(withDuration: 0.3, animations: {
            self.blackView.alpha = 0
        }) { (success) in
            self.blackView.removeFromSuperview()
            self.groupCV.reloadData()
            self.sideYearIsShown = false
            self.blackViewAlphaValue = 0
        }
    }
    
    //MARK: - Actions
    @objc private func addNewGroupButtonPressed(_ sender: Any) {
        ui_newGroupNameTextField.text = ""
        ui_newGroupNameTextField.becomeFirstResponder()
        setupBlackView()
        animateIn()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshNumberOfFolders"), object: nil)
    }

    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        ui_searchBar.text = ""
        ui_searchBar.becomeFirstResponder()
        searchBarViewHeight.constant = 56
        UIView.animate(withDuration: 0.25) {
            self.ui_searchBarView.layoutIfNeeded()
        }
    }
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        _settingsLauncher.showSettings()
    }
    
    @objc private func showYearSelector() {
        if !sideYearIsShown {
            NotificationCenter.default.post(name: NSNotification.Name("showHideSideYearSelector"), object: nil)
            blackView.frame = view.frame
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDissmiss)))
            view.addSubview(blackView)
            UIView.animate(withDuration: 0.3) {
                self.blackView.alpha = 0.5
                self.sideYearIsShown = true
            }
        } else {
            handleDissmiss()
        }
    }
    
    @objc private func sideYearAnchorChangeHasBegan() {
        blackView.frame = view.frame
        view.addSubview(blackView)
    }
    
    @objc private func sideYearAnchorIsChanging(_ notification: NSNotification) {
        if  let notificationData = notification.userInfo,
            let sideAnchorConstant = notificationData["sideAnchorValue"] as? CGFloat {
            blackViewAlphaValue = 0.5 - ( (sideAnchorConstant*0.5) / -250 )
            UIView.animate(withDuration: 0) {
                self.blackView.alpha = self.blackViewAlphaValue
            }
        }
    }
    
    @objc private func sideYearAnchorChangeEnded(_ notification: NSNotification) {
        if  let notificationData = notification.userInfo,
            let isSideYearSelectorOpen = notificationData["isSideYearSelectorOpen"] as? Bool {
                self.sideYearIsShown = isSideYearSelectorOpen
            if isSideYearSelectorOpen {
                UIView.animate(withDuration: 0.2) {
                    self.blackView.alpha = 0.5
                }
                blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDissmiss)))
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.blackView.alpha = 0
                }) { (_) in
                    self.blackView.removeFromSuperview()
                    self.blackViewAlphaValue = 0
                }
            }
        }
    }
    
    //MARK: - Prepare for Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _currentYear.getGroupCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell_group = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_group", for: indexPath) as! GroupCollectionViewCell

        if let group = _currentYear.getGroup(atIndex: indexPath.row, isListFiltered) {
            cell_group.setValues(group, fontSize: collectionViewFontSize)
        }

        cell_group.layer.cornerRadius = 8
        cell_group.layer.shadowColor = UIColor.gray.cgColor
        cell_group.layer.shadowOpacity = 0.5
        cell_group.layer.shadowRadius = 5
        cell_group.layer.shadowOffset = .zero
        cell_group.layer.shadowPath = UIBezierPath(rect: cell_group.bounds).cgPath
        cell_group.layer.shouldRasterize = true
        cell_group.layer.masksToBounds = false
        
        cell_group.delegate = self
        return cell_group
    }
}

extension GroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = groupCV.frame.size.width - 32
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
        let attr = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attr)
    }
}

extension GroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ui_createGroupView.endEditing(false)
        return true
    }
}
