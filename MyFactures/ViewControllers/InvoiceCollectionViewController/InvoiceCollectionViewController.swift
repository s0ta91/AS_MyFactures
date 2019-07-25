//
//  InvoiceTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet
import StoreKit

class InvoiceCollectionViewController: UIViewController {
    
    //MARK: - Declarations
    //TODO: Outlets
    @IBOutlet weak var invoiceCollectionView: UICollectionView!
    @IBOutlet weak var ui_searchBarView: UIView!
    @IBOutlet weak var ui_searchBar: UISearchBar!
    
    @IBOutlet weak var ui_searchBarHeightConstraint: NSLayoutConstraint!
    
    let addFloatingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let plusImage = UIImage(named: "plus_button_white")
        button.setImage(plusImage, for: .normal)
//        button.backgroundColor = UIColor(named: "navBarTint")
        button.backgroundColor = .black
        button.setFloatingButton()
        button.addTarget(self, action: #selector(addNewInvoiceButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    let BUTTON_SIZE: CGFloat = 56
    
    private var ui_searchButton: UIBarButtonItem!
    
    let addNewInvoiceStoryboard = UIStoryboard(name: "AddNewInvoiceViewController", bundle: .main)
    let PDFStoryboard = UIStoryboard(name: "PDFViewController", bundle: .main)
    
    //TODO: Data reveived from previous VC
    var _ptManager: Manager?
    var _ptCurrentGroup: Group?
    var _ptYear: Year?
    var _ptFontSize: CGFloat?
    
    //TODO: Internal variables
    private var _invoiceCollectionManager: Manager!
    private var _invoiceCollectionCurrentGroup: Group!
    private var _invoiceCollectionCurrentYear: Year!
    
    // To store the months that need to be shown if they contains at least an invoice
    private var _monthToShow: [Int] = []
    
    // To define if the list is filtered by a search or not
    private var isListFiltered = false
    var searchText: String = ""
    var collectionViewFontSize: CGFloat!
    
    let searchButtonImage = UIImage(named: "search(grey)")
    
    //TODO: Localized text
    let deleteDocumentTitle = NSLocalizedString("Delete this document ?", comment: "")
    let deleteActionTitle = NSLocalizedString("Delete", comment: "")
    let cancelActionTitle = NSLocalizedString("Cancel", comment: "")
    let editActionTitle = NSLocalizedString("Edit", comment: "")
    let shareActionTitle = NSLocalizedString("Share", comment: "")
    let noDocumentAssociatedTitle = NSLocalizedString("No file assiciated to this document", comment: "")
    let descriptionStr = NSLocalizedString("Tap the 'New document' icon to create a new document", comment: "")
    
    //MARK: - Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        setupReviewController()
        invoiceCollectionView.dataSource = self
        invoiceCollectionView.delegate = self
        invoiceCollectionView.emptyDataSetSource = self
        setupFloatingButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        invoiceCollectionView.clipsToBounds = false
        
        // Check if data are reveived from previous VC otherwise app fatal crash because it can't run without these data
        checkReceivedData()
        setNavigationBarInfo()
        _invoiceCollectionManager.setHeaderClippedToBound(invoiceCollectionView)
        
        invoiceCollectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("enteringLeavingGroupVC"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("enteringLeavingGroupVC"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private functions
    /** add floating button */
    private func setupFloatingButton() {
        view.addSubview(addFloatingButton)
        addFloatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addFloatingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        addFloatingButton.heightAnchor.constraint(equalToConstant: BUTTON_SIZE ).isActive = true
        addFloatingButton.widthAnchor.constraint(equalToConstant: BUTTON_SIZE).isActive = true
        addFloatingButton.layer.cornerRadius = BUTTON_SIZE / 2
    }
    
    /** Show the review window to note the app */
    private func setupReviewController() {
        SKStoreReviewController.requestReview()
    }
    
    /** Check if the data recieved from previous controller are ok */
    private func checkReceivedData () {
        if let _manager = _ptManager {
            _invoiceCollectionManager = _manager
        }else {
            fatalError("_manager data are missing")
        }
        
        if let _group = _ptCurrentGroup {
            _invoiceCollectionCurrentGroup = _group
        }else {
            fatalError("_group data are missing")
        }
        
        if let _year = _ptYear {
            _invoiceCollectionCurrentYear = _year
        }else {
            fatalError("_year data are missing")
        }
        
        if let receivedFontSize = _ptFontSize {
            collectionViewFontSize = receivedFontSize
        }
    }
    
    //TODO: Set the navigationBar title with the name of the current group
    private func setNavigationBarInfo () {
        self.title = _invoiceCollectionCurrentGroup.title
        let searchButton = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(search))
        let selectedCategoryName = _invoiceCollectionManager.getSelectedCategory().title
        let selectCategoryButon = UIBarButtonItem(title: selectedCategoryName, style: .plain, target: self, action: #selector(showCategorySelector))
        navigationItem.rightBarButtonItems = [searchButton, selectCategoryButon]
    }

    //TODO: Retrieve the month for the section index
    private func getCurrentMonth (atIndex monthIndex: Int) -> Month? {
        let selectedCategory = _invoiceCollectionManager.getSelectedCategory()
        let month = _invoiceCollectionCurrentGroup.getMonth(atIndex: monthIndex) ?? nil
        if month != nil {
            month?.setInvoiceList(for: selectedCategory, searchText: searchText)
        }
        return month
    }
    
    //TODO: Get the number of sections for the current group
    private func getNumberOfSections () -> Int {
        _monthToShow.removeAll()
        var numberOfSection = 0
        for monthId in 0...11 {
            let numberOfInvoiceInSection = getNumberOfInvoice(atMonthIndex: monthId)
            if numberOfInvoiceInSection > 0 {
                _monthToShow.append(monthId)
                numberOfSection = numberOfSection + 1
            }
        }
        return numberOfSection
    }
    
    //TODO: Get the number of Invoice by section (by month)
    private func getNumberOfInvoice (atMonthIndex monthIndex: Int) -> Int {
        var numberOfInvoice = 0
        if let month = getCurrentMonth(atIndex: monthIndex) {
            numberOfInvoice = month.getInvoiceCount()
        }
        return numberOfInvoice
    }
    
    private func getSelectedInvoice (for month: Month, atInvoiceIndex invoiceIndex: Int) -> Invoice? {
        var invoice: Invoice? = nil
        invoice = month.getInvoice(atIndex: invoiceIndex, isListFiltered)
        return invoice
    }
    
    //TODO: Create the function to delete a cell
    func delete(invoice: InvoiceCollectionViewCell) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoice) {
            let monthIndex = _monthToShow[indexPath.section]
            let sectionIndexSet = IndexSet(integer: indexPath.section)
            if let month = self.getCurrentMonth(atIndex: monthIndex),
                let invoiceToDelete = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row) {
                let alert = UIAlertController(title: deleteDocumentTitle, message: invoiceToDelete.detailedDescription, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: deleteActionTitle, style: .destructive, handler: { (_) in
                    
                    // Delete invoice object from DB
                    _ = month.removeInvoice(invoice: invoiceToDelete)
                    month.removeFromInvoiceToShow (atIndex: indexPath.row)
                    
                    // If there isn't any invoice left we need to delete the section from the collectionView
                    if self.getNumberOfInvoice(atMonthIndex: monthIndex) == 0 {
                        self.invoiceCollectionView.deleteSections(sectionIndexSet)
                        self.invoiceCollectionView.reloadData()
                    }else { // otherwise we can delete only the item
                        self.invoiceCollectionView.deleteItems(at: [indexPath])
                        self.invoiceCollectionView.reloadSections(sectionIndexSet)
                        self.invoiceCollectionView.reloadData()
                    }
                })
                
                let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: { (_) in
                })
                
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: Create the function to share the invoice
    func share(invoice: InvoiceCollectionViewCell, buttonPressed: UIButton) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoice) {
            
            let monthIndex = _monthToShow[indexPath.section]
            if let month = getCurrentMonth(atIndex: monthIndex),
                let selectedInvoice = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row),
                let invoiceIdentifier = selectedInvoice.identifier,
                let invoiceDocumentExtension = selectedInvoice.documentType,
                let documentToShareUrl = SaveManager.loadDocument(withIdentifier: invoiceIdentifier, andExtension: invoiceDocumentExtension) {
                let activityViewController = UIActivityViewController(activityItems: [documentToShareUrl], applicationActivities: nil)
                
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = invoice.contentView
                    popoverController.sourceRect = CGRect(x: buttonPressed.frame.midX, y: buttonPressed.frame.maxY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = .up
                }
                present(activityViewController, animated: true, completion: nil)
            }else {
                /*** DEBUG ***/
//                let month = getCurrentMonth(atIndex: monthIndex)
//                let selectedInvoice = getSelectedInvoice(for: month!, atInvoiceIndex: indexPath.row)
//                print("invoice: \(selectedInvoice)")
                /*******************/
                let alertController = UIAlertController(title: noDocumentAssociatedTitle, message: nil, preferredStyle: .alert)
                let validAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
//                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(validAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: - Create the function to modify an invoice
    func modify(invoice: InvoiceCollectionViewCell) {
        if let destinationVC = addNewInvoiceStoryboard.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController,
            let cell_indexPath = invoiceCollectionView.indexPath(for: invoice) {
            
                let monthIndex = _monthToShow[cell_indexPath.section]
                if let month = getCurrentMonth(atIndex: monthIndex),
                    let selectedInvoice = getSelectedInvoice(for: month, atInvoiceIndex: cell_indexPath.row) {
                    destinationVC._modifyInvoice = true
                    destinationVC._ptManager = _invoiceCollectionManager
                    destinationVC._ptYear = _invoiceCollectionCurrentYear
                    destinationVC._ptGroup = _invoiceCollectionCurrentGroup
                    destinationVC._ptMonth = month
                    destinationVC._ptInvoice = selectedInvoice
                }
                destinationVC.modalTransitionStyle = .coverVertical
                present(destinationVC, animated: true, completion: nil)
        }
    }
    
    @objc func search () {
        ui_searchBar.text = ""
        ui_searchBar.becomeFirstResponder()
        ui_searchBarHeightConstraint.constant = 56
        UIView.animate(withDuration: 0.25) {
            self.ui_searchBarView.layoutIfNeeded()
        }
    }
    
    @objc private func showCategorySelector() {
        let manageCategoryStoryboard = UIStoryboard(name: "ManageCategoryTableViewController", bundle: .main)
        if let manageCategoryVC = manageCategoryStoryboard.instantiateViewController(withIdentifier: "ManageCategoryTableViewController") as? ManageCategoryTableViewController {
            manageCategoryVC._ptManager = self._ptManager
            manageCategoryVC.modalTransitionStyle = .coverVertical
            present(manageCategoryVC, animated: true, completion: nil)
        }        
    }
    
    @objc private func addNewInvoiceButtonPressed(_ sender: UIButton) {
        if let destinationVC = addNewInvoiceStoryboard.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController {
            destinationVC._ptManager = self._invoiceCollectionManager
            destinationVC._ptYear = self._invoiceCollectionCurrentYear
            destinationVC._ptGroup = self._invoiceCollectionCurrentGroup
            self.present(destinationVC, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation to manageCategoyVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageCategoryVC"{
            if let navigationVC = segue.destination as? UINavigationController,
                let destinationVC = navigationVC.viewControllers.first as? ManageCategoryTableViewController {
                    destinationVC._ptManager = _invoiceCollectionManager
            }
        }
    }
}

//MARK: - Extensions
//TODO: Create the extension for the CollectionView Datasource here :
extension InvoiceCollectionViewController: UICollectionViewDataSource  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headerDate: String = ""
        var monthAmount: String = ""
        var invoiceHeaderView: HeaderInvoiceCollectionReusableView!
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            invoiceHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cell_invoiceHeader", for: indexPath) as? HeaderInvoiceCollectionReusableView
            let monthIndex = _monthToShow[indexPath.section]
            if let month = getCurrentMonth(atIndex: monthIndex) {
                headerDate = "\(month.month) \(_invoiceCollectionCurrentYear.year)"
                monthAmount = String(describing: month.getTotalAmount())
            }
            invoiceHeaderView.setValuesForHeader(headerDate, monthAmount, fontSize: collectionViewFontSize)
            
        default:
            assert(false, "Unexpected element kind")
        }
        return invoiceHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthIndex = _monthToShow[section]
        return getNumberOfInvoice(atMonthIndex: monthIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_invoice = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_invoice", for: indexPath) as! InvoiceCollectionViewCell
        guard let month = getCurrentMonth(atIndex: _monthToShow[indexPath.section]) else {fatalError("no month found at index \(_monthToShow[indexPath.section])")}
        if let invoiceToShow = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row) {
            cell_invoice.setValues(forInvoice: invoiceToShow, fontSize: collectionViewFontSize)
        }
        
        cell_invoice.delegate = self
        cell_invoice.layer.borderWidth = 1.0
        cell_invoice.layer.borderColor = UIColor.clear.cgColor
        cell_invoice.layer.shadowColor = UIColor.lightGray.cgColor
        cell_invoice.layer.shadowOffset = CGSize(width:2,height: 2)
        cell_invoice.layer.shadowRadius = 4.0
        cell_invoice.layer.shadowOpacity = 1.0
//        cell_invoice.layer.cornerRadius = 4
        cell_invoice.layer.masksToBounds = false;
        cell_invoice.layer.shadowPath = UIBezierPath(rect:cell_invoice.bounds).cgPath
        return cell_invoice
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let invoiceCell = collectionView.cellForItem(at: indexPath) as! InvoiceCollectionViewCell
        modify(invoice: invoiceCell)
    }
}

extension InvoiceCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = invoiceCollectionView.frame.size.width - 32
        return CGSize(width: width, height: 115)
    }
}

//TODO: Create the delegate to be conform to the cell
extension InvoiceCollectionViewController: InvoiceCollectionViewCellDelegate {
    
    func showAvailableActions(invoiceCell: InvoiceCollectionViewCell, buttonPressed: UIButton) {
        let actionsController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let modifyAction = UIAlertAction(title: editActionTitle, style: .default) { (action: UIAlertAction) in
//            self.modify(invoice: invoiceCell)
//        }
        let deleteAction = UIAlertAction(title: deleteActionTitle, style: .destructive) { (_) in
            self.delete(invoice: invoiceCell)
        }
        let shareAction = UIAlertAction(title: shareActionTitle, style: .default) { (_) in
            self.share(invoice: invoiceCell, buttonPressed: buttonPressed)
        }
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        
//        actionsController.addAction(modifyAction)
        actionsController.addAction(shareAction)
        actionsController.addAction(deleteAction)
        actionsController.addAction(cancelAction)
        
        if let popoverController = actionsController.popoverPresentationController {
            popoverController.sourceView = invoiceCell.contentView
            popoverController.sourceRect = CGRect(x: buttonPressed.frame.midX, y: buttonPressed.frame.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
        present(actionsController, animated: true, completion: nil)
    }
    
    func showPdfDocument(invoiceCell: InvoiceCollectionViewCell) {
        guard let indexPath = invoiceCollectionView.indexPath(for: invoiceCell) else {return print("No cell found")}
        let monthIndex = _monthToShow[indexPath.section]
        
        if let destinationVC = PDFStoryboard.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController,
            let month = getCurrentMonth(atIndex: monthIndex),
            let selectedInvoice = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row),
            let invoiceIdentifier = selectedInvoice.identifier,
            let invoiceDocumentExtension = selectedInvoice.documentType,
            let documentURL = SaveManager.loadDocument(withIdentifier: invoiceIdentifier, andExtension: invoiceDocumentExtension) {
                destinationVC._ptManager = _invoiceCollectionManager
                destinationVC._ptDocumentURL = documentURL
                destinationVC._ptDocumentType = invoiceDocumentExtension
                destinationVC.modalTransitionStyle = .crossDissolve
                self.present(destinationVC, animated: true, completion: nil)
        }else {
            let alertController = UIAlertController(title: noDocumentAssociatedTitle, message: nil, preferredStyle: .alert)
            let validAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(validAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension InvoiceCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isListFiltered = true
        searchBar.resignFirstResponder()
        if let searchBarText = searchBar.text {
            if searchBarText != "" {
                searchText = searchBarText
            }else {
                searchBarCancelButtonClicked(searchBar)
            }
        }
        invoiceCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isListFiltered = false
        ui_searchBarHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.ui_searchBarView.layoutIfNeeded()
        }
        searchText = ""
        invoiceCollectionView.reloadData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            self.searchText = ""
        }
        invoiceCollectionView.reloadData()
    }
}

extension InvoiceCollectionViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "documentCollectionViewBackground_128")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = descriptionStr
        let attr = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)]
        return NSAttributedString(string: str, attributes: attr)
    }
}
