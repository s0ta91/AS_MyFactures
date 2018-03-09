//
//  InvoiceTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    //TODO: Internal variables
    private var _invoiceCollectionManager: Manager!
    private var _invoiceCollectionCurrentGroup: Group!
    private var _invoiceCollectionCurrentYear: Year!
    
    // To store the months that need to be shown if they contains at least an invoice
    private var _monthToShow: [Int] = []
    private var isListFiltered = false
    var invoiceListResult: Results<Invoice>!
    var searchText: String = ""
    
    let searchButtonImage = UIImage(named: "search(grey)")
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        invoiceCollectionView.dataSource = self
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
    }
    
    //TODO: Set the navigationBar title with the name of the current group
    private func setNavigationBarInfo () {
        self.title = _invoiceCollectionCurrentGroup.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(search))
    }
    
    //TODO: Retrieve the month for the section index
    private func getCurrentMonth (atIndex monthIndex: Int) -> Month? {
        let returnedMonth = _invoiceCollectionCurrentGroup.getMonth(atIndex: monthIndex) ?? nil
        if returnedMonth != nil {
            setInvoiceList(forMonth: returnedMonth!, forInvoiceNameParts: searchText)
        }
        return returnedMonth
    }
    
    private func setInvoiceList (forMonth month: Month, forInvoiceNameParts invoiceNameParts: String = "") {
        invoiceListResult = month.setInvoiceList(containing: invoiceNameParts)
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
        //FIXME: - Bug here when swipe on groupCell to the right in the TOTAL cell of the second cell(maybe others too)
        let selectedCategory = _invoiceCollectionManager.getSelectedCategory()
        if let month = getCurrentMonth(atIndex: monthIndex) {
            if selectedCategory.title == "Toutes les catégories" {
                numberOfInvoice = month.getInvoiceCount()
            }else {
                numberOfInvoice = month.getInvoiceListFilteredCount(forCategory: selectedCategory)
            }
        }
        return numberOfInvoice
    }
    
    //TODO: Create the function to delete a cell
    func delete(invoice: InvoiceCollectionViewCell) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoice) {
            let monthIndex = _monthToShow[indexPath.section]
            if let month = self.getCurrentMonth(atIndex: monthIndex),
                let invoiceToDelete = month.getInvoice(atIndex: indexPath.row) {
                let alert = UIAlertController(title: "Supprimer cette facture ?", message: invoiceToDelete.detailedDescription, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive, handler: { (_) in
                    
                    // Delete the photo from the database
                    _ = month.removeInvoice(invoice: invoiceToDelete)

                    // reload the collectionView to re-calculate the number of section to show
                    self.invoiceCollectionView.deleteItems(at: [indexPath])
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
            let month = _invoiceCollectionCurrentGroup.getMonth(atIndex: _monthToShow[indexPath.section]) {
            if let selectedInvoice = month.getInvoice(atIndex: indexPath.row),
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
                let invoice = month.getInvoice(atIndex: cell_indexPath.row) {
                destinationVC._modifyInvoice = true
                destinationVC._ptManager = _invoiceCollectionManager
                destinationVC._ptYear = _invoiceCollectionCurrentYear
                destinationVC._ptGroup = _invoiceCollectionCurrentGroup
                destinationVC._ptMonth = month
                destinationVC._ptInvoice = invoice
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
            let selectedCategory = _invoiceCollectionManager.getSelectedCategory()
            if let month = getCurrentMonth(atIndex: monthIndex) {
                headerDate = "\(month.month) \(_invoiceCollectionCurrentYear.year)"
                if selectedCategory.title == "Toutes les catégories" {
                    monthAmount = String(describing: month.getTotalAmount(forMonthIndex: indexPath.section, withFilter: false))
                }else {
                    monthAmount = String(describing: month.getTotalAmount(forMonthIndex: indexPath.section, withFilter: true, forCategory: selectedCategory))
                }
            }
            invoiceHeaderView._ptManager = _invoiceCollectionManager
            invoiceHeaderView.setValuesForHeader(headerDate, monthAmount)
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
        var invoice: Invoice? = nil
        guard let month = getCurrentMonth(atIndex: monthIndex) else {fatalError("no month found at index \(monthIndex)")}
        let selectedCategory = _invoiceCollectionManager.getSelectedCategory()
        print("invoiceList: \(month._invoiceListToShow)")
        if selectedCategory.title == "Toutes les catégories" {
            invoice = month.getInvoice(atIndex: indexPath.row, isListFiltered)
        }else {
            invoice = month.getInvoiceFiltered(ForCategory: selectedCategory, atIndex: indexPath.row)
        }
        if let invoiceToShow = invoice {
            cell_invoice.setValues(forInvoice: invoiceToShow)
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
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "PDFViewController") as? PDFViewController,
            let indexPath = invoiceCollectionView.indexPath(for: invoiceCell),
            let month = _invoiceCollectionCurrentGroup.getMonth(atIndex: _monthToShow[indexPath.section]),
            let selectedInvoice = month.getInvoice(atIndex: indexPath.row) {
            
            if let invoiceIdentifier = selectedInvoice.identifier,
                let invoiceDocumentExtension = selectedInvoice.documentType,
                let documentURL = SaveManager.loadDocument(withIdentifier: invoiceIdentifier, andExtension: invoiceDocumentExtension) {
                destinationVC._ptManager = _invoiceCollectionManager
                destinationVC._ptDocumentURL = documentURL
                destinationVC._ptDocumentType = invoiceDocumentExtension
                destinationVC.modalTransitionStyle = .crossDissolve
                self.present(destinationVC, animated: true, completion: nil)
            }
            else {
                let alertController = UIAlertController(title: "Aucun document n'est attaché à cette facture", message: nil, preferredStyle: .alert)
                let validAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(validAction)
                self.present(alertController, animated: true, completion: nil)
                
                print("Something went wrong")
            }
        }
    }
}

extension InvoiceCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isListFiltered = true
        searchBar.resignFirstResponder()
        if let searchBarText = searchBar.text {
            searchText = searchBarText
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
}
