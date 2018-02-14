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
    
    func checkReceivedData () {
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
    
    func getCurrentMonth (atIndex monthIndex: Int) -> Month? {
        return _invoiceCollectionCurrentGroup.getMonth(atIndex: monthIndex) ?? nil
    }
    
    func getNumberOfSections () -> Int {
        return _invoiceCollectionCurrentGroup.getMonthCount()
    }
    
    func getNumberOfInvoice (atMonthIndex monthIndex: Int) -> Int {
        var numberOfInvoice = 0
        if let month = getCurrentMonth(atIndex: monthIndex) {
            numberOfInvoice = month.getInvoiceCount()
        }
        return numberOfInvoice
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
        return cell_invoice
    }
    
    
}
