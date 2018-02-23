//
//  InvoiceTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class InvoiceCollectionViewController: UIViewController {
    
    //MARK: - Declarations
    //TODO: Outlets
    @IBOutlet weak var invoiceCollectionView: UICollectionView!
    
    //TODO: Data reveived from previous VC
    var _ptManager: Manager?
    var _ptCurrentGroup: Group?
    var _ptYear: Year?
    
    //TODO: Internal variables
    private var _invoiceCollectionManager: Manager!
    private var _invoiceCollectionCurrentGroup: Group!
    private var _invoiceCollectionCurrentYear: Year!
    
    // To store the months that need to shown if they contains at least an invoice
    private var monthToShow: [Int] = []

    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        invoiceCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        invoiceCollectionView.clipsToBounds = false
        invoiceCollectionView.reloadData()
        // Check if data are reveived from previous VC otherwise app fatal crash because it can't run without these data
        checkReceivedData()
        setNavigationBarInfo()

        _invoiceCollectionManager.setHeaderClippedToBound(invoiceCollectionView)
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
        monthToShow.removeAll()
        var numberOfSection = 0
        for monthId in 0...11 {
            let numberOfInvoiceInSection = getNumberOfInvoice(atMonthIndex: monthId)
            if numberOfInvoiceInSection > 0 {
                monthToShow.append(monthId)
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
    
//    @IBAction func newActionButtonPressed(_ sender: UIButton) {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let addInvoiceAction = UIAlertAction(title: "Ajouter une facture", style: .default) { (action: UIAlertAction) in
//            if let addInvoiceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceNavigationController"),
//                let destinationVC = addInvoiceVC.childViewControllers.first as? AddNewInvoiceViewController {
//                destinationVC._ptManager = self._invoiceCollectionManager
//                destinationVC._ptYear = self._invoiceCollectionCurrentYear
//                destinationVC._ptGroup = self._invoiceCollectionCurrentGroup
//                self.present(addInvoiceVC, animated: true, completion: nil)
//            }
//        }
//
//        let addCategoryAction = UIAlertAction(title: "Créer une nouvelle catégorie", style: .default) { (action: UIAlertAction) in
//
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        actionSheet.addAction(addInvoiceAction)
//        actionSheet.addAction(addCategoryAction)
//        actionSheet.addAction(cancelAction)
//
//        present(actionSheet, animated: true, completion: nil)
//    }
    
    @IBAction func addNewInvoiceButtonPressed(_ sender: UIButton) {
//        if let addInvoiceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceNavigationController"),
//            let destinationVC = addInvoiceVC.childViewControllers.first as? AddNewInvoiceViewController {
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
        if segue.identifier == "manageCategoryVC" {
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
            let monthIndex = monthToShow[indexPath.section]
            if let month = getCurrentMonth(atIndex: monthIndex) {
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
        let monthIndex = monthToShow[section]
        return getNumberOfInvoice(atMonthIndex: monthIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_invoice = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_invoice", for: indexPath) as! InvoiceCollectionViewCell
        let monthIndex = monthToShow[indexPath.section]
        if let month = getCurrentMonth(atIndex: monthIndex),
            let invoice = month.getInvoice(atIndex: indexPath.row) {
            let categoryName = invoice.categoryObject?.title
            cell_invoice._ptManager = _invoiceCollectionManager
            cell_invoice.setValues(String(describing: invoice.amount), categoryName, invoice.detailedDescription)
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
    
    //TODO: Create the function to delete a cell
    func delete(invoiceCell: InvoiceCollectionViewCell) {
        if let indexPath = invoiceCollectionView.indexPath(for: invoiceCell) {
            let monthIndex = monthToShow[indexPath.section]
            if let month = self.getCurrentMonth(atIndex: monthIndex),
                let invoiceToDelete = month.getInvoice(atIndex: indexPath.row) {
                let alert = UIAlertController(title: "Supprimer cette facture ?", message: invoiceToDelete.detailedDescription, preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive, handler: { (_) in
                
                    // Delete the photo from the database
                    _ = month.removeInvoice(invoice: invoiceToDelete)
                    // reload the collectionView to re-calculate the number of section to show
                    self.invoiceCollectionView.reloadData()
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
    
    func modify(invoiceCell: InvoiceCollectionViewCell) {

//        if let addNewinvoiceNC = storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceNavigationController"),
//            let destinationVC = addNewinvoiceNC.childViewControllers.first as? AddNewInvoiceViewController,
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController,
            let cell_indexPath = invoiceCollectionView.indexPath(for: invoiceCell) {

                let monthIndex = monthToShow[cell_indexPath.section]
                if let month = _invoiceCollectionCurrentGroup.getMonth(atIndex: monthIndex),
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
}

