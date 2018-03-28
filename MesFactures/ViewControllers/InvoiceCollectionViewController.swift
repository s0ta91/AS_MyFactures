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

class InvoiceCollectionViewController: UIViewController {
    
    //MARK: - Declarations
    //TODO: Outlets
    @IBOutlet weak var invoiceCollectionView: UICollectionView!
    @IBOutlet weak var ui_searchBarView: UIView!
    @IBOutlet weak var ui_searchBar: UISearchBar!
    
    @IBOutlet weak var ui_searchBarHeightConstraint: NSLayoutConstraint!
    private var ui_searchButton: UIBarButtonItem!
    
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
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        invoiceCollectionView.dataSource = self
        invoiceCollectionView.delegate = self
        invoiceCollectionView.emptyDataSetSource = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - PRIVATE FUNCTIONS
    //TODO: Check if the data recieved from previous controller are ok
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(search))
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
                let alert = UIAlertController(title: "Supprimer cette facture ?", message: invoiceToDelete.detailedDescription, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive, handler: { (_) in
                    
                    // Delete the photo from the database
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
                
                let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
                })
                
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: Create the function to share the invoice
    func share(invoice: InvoiceCollectionViewCell) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoice),
            let month = getCurrentMonth(atIndex: indexPath.section) {
            if let selectedInvoice = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row),
                let invoiceIdentifier = selectedInvoice.identifier,
                let invoiceDocumentExtension = selectedInvoice.documentType,
                let documentToShareUrl = SaveManager.loadDocument(withIdentifier: invoiceIdentifier, andExtension: invoiceDocumentExtension) {
                let activityViewController = UIActivityViewController(activityItems: [documentToShareUrl], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            }else {
                let alertController = UIAlertController(title: "Aucun document n'est attaché à cette facture", message: nil, preferredStyle: .alert)
                let validAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(validAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //TODO: - Create the function to modify an invoice
    func modify(invoice: InvoiceCollectionViewCell) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController,
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
    
    
    @IBAction func addNewInvoiceButtonPressed(_ sender: UIButton) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController {
            destinationVC._ptManager = self._invoiceCollectionManager
            destinationVC._ptYear = self._invoiceCollectionCurrentYear
            destinationVC._ptGroup = self._invoiceCollectionCurrentGroup
            self.present(destinationVC, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        switch kind {
        case UICollectionElementKindSectionHeader:
            let invoiceHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cell_invoiceHeader", for: indexPath) as! HeaderInvoiceCollectionReusableView
            let monthIndex = _monthToShow[indexPath.section]
            if let month = getCurrentMonth(atIndex: monthIndex) {
                headerDate = "\(month.month) \(_invoiceCollectionCurrentYear.year)"
                monthAmount = String(describing: month.getTotalAmount())
            }
            invoiceHeaderView._ptManager = _invoiceCollectionManager
            invoiceHeaderView.setValuesForHeader(headerDate, monthAmount, fontSize: collectionViewFontSize)
            return invoiceHeaderView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthIndex = _monthToShow[section]
        return getNumberOfInvoice(atMonthIndex: monthIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_invoice = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_invoice", for: indexPath) as! InvoiceCollectionViewCell
        cell_invoice._ptManager = _invoiceCollectionManager
        let monthIndex = _monthToShow[indexPath.section]
        guard let month = getCurrentMonth(atIndex: monthIndex) else {fatalError("no month found at index \(monthIndex)")}
        let invoice = getSelectedInvoice(for: month, atInvoiceIndex: indexPath.row)
        if let invoiceToShow = invoice {
            cell_invoice.setValues(forInvoice: invoiceToShow, fontSize: collectionViewFontSize)
        }
        cell_invoice.delegate = self
        cell_invoice.layer.borderWidth = 1.0
        cell_invoice.layer.borderColor = UIColor.clear.cgColor
        cell_invoice.layer.shadowColor = UIColor.lightGray.cgColor
        cell_invoice.layer.shadowOffset = CGSize(width:2,height: 2)
        cell_invoice.layer.shadowRadius = 2.0
        cell_invoice.layer.shadowOpacity = 1.0
        cell_invoice.layer.masksToBounds = false;
        cell_invoice.layer.shadowPath = UIBezierPath(rect:cell_invoice.bounds).cgPath
        return cell_invoice
    }
}

extension InvoiceCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = invoiceCollectionView.frame.size.width
        return CGSize(width: width, height: 115)
    }
}


//TODO: Create the delegate to be conform to the cell
extension InvoiceCollectionViewController: InvoiceCollectionViewCellDelegate {
    
    func showAvailableActions(invoiceCell: InvoiceCollectionViewCell) {
        let actionsController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let modifyAction = UIAlertAction(title: "Modifier", style: .default) { (action: UIAlertAction) in
            self.modify(invoice: invoiceCell)
        }
        let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive) { (_) in
            self.delete(invoice: invoiceCell)
        }
        let shareAction = UIAlertAction(title: "Partager", style: .default) { (_) in
            self.share(invoice: invoiceCell)
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        
        actionsController.addAction(modifyAction)
        actionsController.addAction(shareAction)
        actionsController.addAction(deleteAction)
        actionsController.addAction(cancelAction)
        present(actionsController, animated: true, completion: nil)
    }
    
    func showPdfDocument(invoiceCell: InvoiceCollectionViewCell) {
        guard let indexPath = invoiceCollectionView.indexPath(for: invoiceCell) else {return print("No cell found")}
        let monthIndex = _monthToShow[indexPath.section]
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController,
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
            let alertController = UIAlertController(title: "Aucun document n'est attaché à cette facture", message: nil, preferredStyle: .alert)
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
        let str = "Tapez sur l'icone 'Nouvelle facture' pour ajouter une facture"
        let attr = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attr)
    }
}
