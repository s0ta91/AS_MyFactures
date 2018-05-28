//
//  ViewController.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var ui_mesfacturesTextField: UITextField!
    @IBOutlet weak var ui_passwordTextField: UITextField!
    @IBOutlet weak var ui_lostPasswordButton: UIButton!
    @IBOutlet weak var ui_connexionButton: UIButton!
    
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /** DEBUG **/
//        DbManager().reInitMasterPassword()
//        _manager.reinitUserDefaultValue(forKey: Settings().USER_EMAIL_KEY)
        
        ui_passwordTextField.text = ""
        
        // Set the font for title
        ui_mesfacturesTextField.font = UIFont(name: "Abuget", size: 100)
        ui_mesfacturesTextField.text = "MyFactures"
        
        // Hide 'createNewPasswordButton' if a user password exists in the iPhone Keychain
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) == true {
            ui_passwordTextField.isHidden = true
            ui_lostPasswordButton.isHidden = true
            ui_connexionButton.isHidden = true
            unlockWithBiometrics()
        }
        
        // Set padding for password textField
        ui_passwordTextField.setPadding()
        ui_passwordTextField.setRadius()
        
        // Set radius for connexion button
        ui_connexionButton.layer.cornerRadius = 5
        
        // Delegation for password textField to have access to textfieldShouldReturn function
        self.ui_passwordTextField.delegate = self
    }

    

    private func unlockWithBiometrics () {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Déverouiller MyFactures", reply: { (isOwnerConfirmed, authError) in
                /**
                    Going back from secondary traitment to firt traitment /
                    Revenir à l'éxécution du code au premier plan après que le traitement en arrière plan (Identifiaction empreinte ou visage) soit effectuée
                 **/
                DispatchQueue.main.async {
                     /** Unlock application **/
                    if isOwnerConfirmed == true {
                        let savedApplicationState = UserDefaults.standard.bool(forKey: "savedApplicationState")
                        // If application returning from background, just dismiss the loginScreen
                        // Else show groupScreen
                        if savedApplicationState {
                            self.modalTransitionStyle = .crossDissolve
                            self.view.endEditing(true)
                            self.dismiss(animated: true, completion: nil)
                            UserDefaults.standard.set(false, forKey: "savedApplicationState")
                        } else {
                            self.displayGroupTableViewController()
                        }
                    }
                    if let error = authError {
                        switch error {
                            case LAError.userCancel:
                                self.showPasswordField()
                            case LAError.biometryLockout:
                                self.showPasswordField()
                            default :
                                 self.showPasswordField()
                        }
                    }
                }
            })
        }
    }
    
    private func showPasswordField () {
        ui_passwordTextField.isHidden = false
        ui_lostPasswordButton.isHidden = false
        ui_connexionButton.isHidden = false
    }

    func displayGroupTableViewController () {
        if let GroupTableVC = storyboard?.instantiateViewController(withIdentifier: "NavGroupContoller") {
            GroupTableVC.modalTransitionStyle = .crossDissolve
            present(GroupTableVC, animated: true, completion: nil)
        }
    }
    
    func displayAddNewInvoideVC() {
        if let addNewInvoideVC = storyboard?.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController {
            present(addNewInvoideVC, animated: false, completion: nil)
        }
    }
    
    private func showAlertMessage (_ errorMessage: String) {
        let alertBox = UIAlertController(title: "Une erreur est survenue", message: errorMessage, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
            self.showPasswordField()
        }))
    }
    
    @IBAction func unlockWithPassword(_ sender: Any) {
        let savedApplicationState = UserDefaults.standard.bool(forKey: "savedApplicationState")
        if let typedPassword = ui_passwordTextField.text,
            let storedPassword = DbManager().getMasterPassword() {
            if typedPassword == storedPassword {
                if savedApplicationState {
                    self.modalTransitionStyle = .crossDissolve
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                    UserDefaults.standard.set(false, forKey: "savedApplicationState")
                } else {
                    displayGroupTableViewController()
                }
            }else {
                _manager.shake(ui_passwordTextField)
            }
        }
    }
    
    @IBAction func LostPassword(_ sender: UIButton) {
        _manager.sendPasswordToUser(fromViewController: self)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

