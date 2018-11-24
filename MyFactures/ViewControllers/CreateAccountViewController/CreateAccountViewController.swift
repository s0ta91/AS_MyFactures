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
    @IBOutlet weak var ui_informationsLabel: UILabel!
    
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }

    var isPasswordSet: Bool = false
    
    //TODO: Localized text
    let informationText = NSLocalizedString("* Your email address will be stored localy. In no case it will be shared or known by thrid parties.", comment: "")
    let emailPlaceholderText = NSLocalizedString("Add your email address *", comment: "")
    let ui_createPasswordButtonText = NSLocalizedString("Add", comment: "")
    let alertErrorTitle = NSLocalizedString("An error occured", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_myfacturesTextField.text = "MyFactures"
        ui_informationsLabel.text = informationText
        
        // Delegation for password textField to have access to textfieldShouldReturn function
        ui_emailTextField.delegate = self
        ui_passwordTextField.delegate = self
        
        ui_emailTextField.setPadding()
        ui_emailTextField.setRadius()
        ui_passwordTextField.setPadding()
        ui_passwordTextField.setRadius()
        ui_createPasswordButton.layer.cornerRadius = 5
        
        if isPasswordSet {
            setPasswordAndDesableField()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setPasswordAndDesableField() {
        ui_emailTextField.placeholder = emailPlaceholderText
        ui_passwordTextField.text = DbManager().getMasterPassword()
        ui_passwordTextField.isEnabled = false
        ui_passwordTextField.backgroundColor = UIColor.darkGray
        ui_createPasswordButton.setTitle(ui_createPasswordButtonText, for: .normal)
    }
    
    func verifyEmail() {
        if (ui_emailTextField.text?.isValidEmail) != false {
            guard let password = ui_passwordTextField.text,
                let emailAddress = ui_emailTextField.text else {
                    Alert.message(title: "Veuillez compléter tous les champs", message: "", vc: self)
                    return
            }
            _manager.createUser(with: password, andEmail: emailAddress)
            Manager.setIsFirstLoad(false)
            let storyboard = UIStoryboard(name: "GroupViewController", bundle: .main)
            let GroupTableVC = storyboard.instantiateViewController(withIdentifier: "NavGroupContoller")
            GroupTableVC.modalTransitionStyle = .crossDissolve
            present(GroupTableVC, animated: true, completion: nil)
            
            
            //            guard let verifyEmailVC = storyboard?.instantiateViewController(withIdentifier: "verifyEmailVC") as? VerifyPasswordViewController else { return }
            //            if let newRandomCode = _manager.generateRandomCode(),
            //                let password = ui_passwordTextField.text {
            //                verifyEmailVC.randomCode = newRandomCode
            //                verifyEmailVC.emailAdress = ui_emailTextField.text!
            //                verifyEmailVC.password = password
            //                if _manager.sendEmail(toEmail: ui_emailTextField.text!, withCode: newRandomCode) {
            //                    verifyEmailVC.modalTransitionStyle = .crossDissolve
            //                    present(verifyEmailVC, animated: true, completion: nil)
            //                } else {
            //                    Alert.message(title: "Une erreur est survenue", message: "", vc: self)
            //                }
            //            }
            //
            //        } else {
            //            //TODO: Faire vibrer le champs
            //            _manager.shake(ui_emailTextField)
            
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
