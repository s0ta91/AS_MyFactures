//
//  SettingsViewController.swift
//  MesFactures
//
//  Created by Sébastien on 27/03/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import Buglife
import Crashlytics

class SettingsViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var firstCategoryView: UIView!
    @IBOutlet weak var resetPasswordSubcategoryView: UIView!
    @IBOutlet weak var cgvView: UIView!
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var contactButton: UIButton!
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.isHidden = true
        navigationController?.navigationBar.tintColor = .white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBottomBorderForViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBottomBorderForViews () {
        let grayColor = UIColor.lightGray
        let viewWidth: CGFloat = 1
        let viewList = [firstCategoryView,resetPasswordSubcategoryView,cgvView,aboutView]
        for view in viewList {
            view?.addBottomBorderWithColor(color: grayColor, width: viewWidth)
        }
    }


    //MARK: - Actions
    
    @IBAction func reportBug(_ sender: UIButton) {
        let appearance = Buglife.shared().appearance
        appearance.barTintColor = UIColor(named: "navBarTint")
        appearance.tintColor = .white
        Buglife.shared().presentReporter()
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func cancelSettingsVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}
