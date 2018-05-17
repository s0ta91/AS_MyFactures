//
//  CreateAccountViewController.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var ui_myfacturesTextField: UITextField!
    @IBOutlet weak var ui_emailTextField: UITextField!
    @IBOutlet weak var ui_passwordTextField: UITextField!
    @IBOutlet weak var ui_createPasswordButton: UIButton!
    
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_myfacturesTextField.text = "MyFactures"
        
        // Delegation for password textField to have access to textfieldShouldReturn function
        ui_passwordTextField.delegate = self
        
        ui_emailTextField.setPadding()
        ui_emailTextField.setRadius()
        ui_passwordTextField.setPadding()
        ui_passwordTextField.setRadius()
        ui_createPasswordButton.layer.cornerRadius = 5
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func verifyEmail() {
        if (ui_emailTextField.text?.isValidEmail) != false {
            guard let verifyEmailVC = storyboard?.instantiateViewController(withIdentifier: "verifyEmailVC") as? verifyPasswordViewController else { return }
            if let newRandomCode = _manager.generateRandomCode(),
                let password = ui_passwordTextField.text {
                verifyEmailVC.randomCode = newRandomCode
                verifyEmailVC.emailAdress = ui_emailTextField.text!
                verifyEmailVC.password = password
                if _manager.sendEmail(toEmail: ui_emailTextField.text!, withCode: newRandomCode) {
                    verifyEmailVC.modalTransitionStyle = .crossDissolve
                    present(verifyEmailVC, animated: true, completion: nil)
                } else {
                    Alert.message(title: "Une erreur est survenue", message: "", vc: self)
                }
            }
            
        } else {
            //TODO: Faire vibrer le champs
            print("Adresse email erronée")
        }
        
    }

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        verifyEmail()
    }
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
