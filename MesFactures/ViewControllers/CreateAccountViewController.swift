//
//  CreateAccountViewController.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ui_myfacturesTextField: UITextField!
    @IBOutlet weak var ui_passwordTextField: UITextField!
    @IBOutlet weak var ui_createPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_myfacturesTextField.text = "MyFactures"
//        ui_passwordTextField.delegate = self
        
        ui_passwordTextField.setPadding()
        ui_passwordTextField.setRadius()
        ui_createPasswordButton.layer.cornerRadius = 5
        
    }
    
    private func createNewUser (){
        if let password = ui_passwordTextField.text,
            let db = DbManager().getDb() {
                db.savePassword(password)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func displayGroupTableViewController () {
        if let GroupTableVC = storyboard?.instantiateViewController(withIdentifier: "NavGroupContoller") {
            GroupTableVC.modalTransitionStyle = .crossDissolve
            present(GroupTableVC, animated: true, completion: nil)
        }
    }

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        createNewUser()
        displayGroupTableViewController()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
