//
//  ViewController.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ui_mesfacturesTextField: UITextField!
    @IBOutlet weak var ui_passwordTextField: UITextField!
    @IBOutlet weak var ui_createNewPasswordButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /** DEBUG **/
//        DbManager().reInitMasterPassword()
        
        showHideCreateNewPasswordButton()
        ui_mesfacturesTextField.font = UIFont(name: "Abuget", size: 100)
        self.ui_passwordTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    private func showHideCreateNewPasswordButton (){
        if let db = DbManager().getDb() {
            if db.hasMasterPassword() == true {
                ui_createNewPasswordButton.isHidden = true
            }else {
                ui_createNewPasswordButton.isHidden = false
            }
        }
    }
    
    
    @IBAction func unlockWithPassword(_ sender: Any) {
        if let typedPassword = ui_passwordTextField.text,
            let storedPassword = DbManager().getMasterPassword(),
            typedPassword == storedPassword {
            displayGroupTableViewController()
        }
    }
    
    func displayGroupTableViewController () {
        if let GroupTableVC = storyboard?.instantiateViewController(withIdentifier: "GroupTableViewController") as? GroupTableViewController {
//            show(GroupTableVC, sender: nil)
            GroupTableVC.modalTransitionStyle = .crossDissolve
            present(GroupTableVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

