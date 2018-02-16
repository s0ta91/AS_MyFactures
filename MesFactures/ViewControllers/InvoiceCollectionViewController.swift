//
//  InvoiceTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class InvoiceCollectionViewController: UIViewController {
    
    @IBOutlet weak var invoiceCollectionView: UICollectionView!
    @IBOutlet weak var ui_newActionButton: UIButton!
    
    // Data reveived from previous VC
    var _ptManager: Manager?
    var _ptCurrentGroup: Group?
    var _ptYear: Year?
    
    // Internal variables
    private var _invoiceCollectionManager: Manager!
    private var _invoiceCollectionCurrentGroup: Group!
    private var _invoiceCollectionCurrentYear: Year!

    override func viewDidLoad() {
        super.viewDidLoad()
        invoiceCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if data are reveived from previous VC otherwise app fatal crash because it can't run without these data
        checkReceivedData()
        setNavigationBarInfo()
        
        _invoiceCollectionManager.setButtonLayer(ui_newActionButton)
        _invoiceCollectionManager.setHeaderClippedToBound(invoiceCollectionView)
        
        /** !! TEST PURPOSE ONLY !! ***
        *** !! DELETE BEFORE LIVE !! **/
        if let group = _invoiceCollectionCurrentGroup {
            group.addMonth("January")
            if let firstMonth = group.getMonth(atIndex: 0) {
                print("monthIndexCreation: \(String(describing: group.getMonthIndex(forMonth: firstMonth)))")
            }
            if let january = group.getMonth(atIndex: 0) {
                january.addInvoice(description: "Aspirateur Dyson", amount: 629.0, categoryName: "Boulanger")
            }
        }
        /*****************************/
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
    }
    
    //TODO: Retrieve the month for the section index
    private func getCurrentMonth (atIndex monthIndex: Int) -> Month? {
        return _invoiceCollectionCurrentGroup.getMonth(atIndex: monthIndex) ?? nil
    }
    
    //TODO: Get the number of sections for the current group
    private func getNumberOfSections () -> Int {
        return _invoiceCollectionCurrentGroup.getMonthCount()
    }
    
    //TODO: Get the number of Invoice by section (by month)
    private func getNumberOfInvoice (atMonthIndex monthIndex: Int) -> Int {
        var numberOfInvoice = 0
        if let month = getCurrentMonth(atIndex: monthIndex) {
            numberOfInvoice = month.getInvoiceCount()
        }
        return numberOfInvoice
    }
    
    @IBAction func newActionButtonPressed(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addInvoiceAction = UIAlertAction(title: "Ajouter une facture", style: .default) { (action: UIAlertAction) in
            if let addInvoiceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceNavigationController"),
                let destinationVC = addInvoiceVC.childViewControllers.first as? AddNewInvoiceViewController {
                destinationVC._ptManager = self._invoiceCollectionManager
                destinationVC._ptYear = self._invoiceCollectionCurrentYear
                destinationVC._ptGroup = self._invoiceCollectionCurrentGroup
                self.present(addInvoiceVC, animated: true, completion: nil)
            }
        }
        
        let addCategoryAction = UIAlertAction(title: "Créer une nouvelle catégorie", style: .default) { (action: UIAlertAction) in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(addInvoiceAction)
        actionSheet.addAction(addCategoryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    */
}

//MARK: - Create the extension for the CollectionView Datasource here :
extension InvoiceCollectionViewController: UICollectionViewDataSource  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("ReusableView")
        var headerDate: String = ""
        var monthAmount: String = ""
        switch kind {
        case UICollectionElementKindSectionHeader:
            let invoiceHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cell_invoiceHeader", for: indexPath) as! HeaderInvoiceCollectionReusableView
            if let month = getCurrentMonth(atIndex: indexPath.section) {
                headerDate = "\(month.month) \(_invoiceCollectionCurrentYear.year)"
                monthAmount = String(describing: month.getTotalAmount(forMonthIndex: indexPath.section))
            }
            invoiceHeaderView._ptManager = _invoiceCollectionManager
            invoiceHeaderView.setValuesForHeader(headerDate, monthAmount)
            return invoiceHeaderView
        default:
            assert(false, "Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNumberOfInvoice(atMonthIndex: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_invoice = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_invoice", for: indexPath) as! InvoiceCollectionViewCell
        if let month = getCurrentMonth(atIndex: indexPath.section),
            let invoice = month.getInvoice(atIndex: indexPath.row) {
            cell_invoice._ptManager = _invoiceCollectionManager
            cell_invoice.setValues(String(describing: invoice.amount), invoice.categoryName, invoice.detailedDescription)
        }
        cell_invoice.delegate = self
        return cell_invoice
    }
}

//MARK: - Create the delegate to be conform to the cell
extension InvoiceCollectionViewController: InvoiceCollectionViewCellDelegate {
    
    //TODO: Create the function to delete a cell
    func delete(invoiceCell: InvoiceCollectionViewCell) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoiceCell) {
            if let month = self.getCurrentMonth(atIndex: indexPath.section),
                let invoiceToDelete = month.getInvoice(atIndex: indexPath.row) {
                
                let alert = UIAlertController(title: "Supprimer cette facture ?", message: invoiceToDelete.detailedDescription, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive, handler: { (_) in
                
                    // Delete the photo from the database
                    month.removeInvoice(invoice: invoiceToDelete)
                    // Delete the photo from the data source
                    self.invoiceCollectionView.deleteItems(at: [indexPath])
                    let indexPaths = self.invoiceCollectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
                    for indexPath in indexPaths {
                        self.invoiceCollectionView.reloadSections(IndexSet(indexPath))
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
    func share(invoiceCell: InvoiceCollectionViewCell) {
        print("Share invoice")
//        if let indexPath = invoiceCollectionView.indexPath(for: invoiceCell) {
            //TODO: Retrieve the document for te selected cell
            /** TEST PURPOSE ONLY **/
            guard let image = UIImage(named: "Boulanger.com") else {return print("image does not exists")}
            /** ***** **/
            
            let shareObject = image
            let activityViewController = UIActivityViewController(activityItems: [shareObject], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
//        }
    }
}

