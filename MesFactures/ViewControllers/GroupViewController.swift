//
//  GroupViewController.swift
//  MesFactures
//
//  Created by Sébastien on 05/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
    
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }
    
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet weak var ui_newGroupButton: UIButton!
    @IBOutlet weak var ui_manageYearButton: UIBarButtonItem!
    @IBOutlet weak var ui_manageGroupButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupCV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNewGroupButtonLayer()

        _manager.addGroup(withTitle: "Achats en ligne")
        _manager.addGroup(withTitle: "Energies")
        _manager.addGroup(withTitle: "Internet")
        _manager.addGroup(withTitle: "Fiches de paie")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setNewGroupButtonLayer () {
        ui_newGroupButton.layer.cornerRadius = 17
        ui_newGroupButton.layer.shadowColor = UIColor.lightGray.cgColor
        ui_newGroupButton.layer.shadowOffset = CGSize(width:0,height: 2)
        ui_newGroupButton.layer.shadowRadius = 2.0
        ui_newGroupButton.layer.shadowOpacity = 1.0
        ui_newGroupButton.layer.masksToBounds = false;
        ui_newGroupButton.layer.shadowPath = UIBezierPath(roundedRect:ui_newGroupButton.bounds, cornerRadius:ui_newGroupButton.layer.cornerRadius).cgPath
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
extension GroupViewController: UICollectionViewDelegate {
    
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
        return _manager.getGroupCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_group = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_group", for: indexPath) as! GroupCollectionViewCell

        if let group = _manager.getGroup(atIndex: indexPath.row) {
            cell_group.setValues(_manager, group)
        }
        
        // Cell's display configuration
        cell_group.layer.cornerRadius = 8
        cell_group.layer.borderWidth = 1.0
        cell_group.layer.borderColor = UIColor.clear.cgColor
        cell_group.layer.shadowColor = UIColor.lightGray.cgColor
        cell_group.layer.shadowOffset = CGSize(width:0,height: 2)
        cell_group.layer.shadowRadius = 2.0
        cell_group.layer.shadowOpacity = 1.0
        cell_group.layer.masksToBounds = false;
        cell_group.layer.shadowPath = UIBezierPath(roundedRect:cell_group.bounds, cornerRadius:cell_group.layer.cornerRadius).cgPath
        
        return cell_group
    }
    
    
}
