//
//  GroupViewController.swift
//  MesFactures
//
//  Created by Sébastien on 05/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {
  
    @IBOutlet weak var groupCV: UICollectionView!
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupCV.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension GroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "group_header", for: indexPath) as! HeaderGroupView
            headerView.headerViewLabel.text = "2018"
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_group = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_group", for: indexPath)

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
