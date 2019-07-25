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
    
    //TODO: Localize text
    let localizedReasonText = NSLocalizedString("Unlock MyFactures", comment: "")
    let alertErrorText = NSLocalizedString("An error occured", comment: "")
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /** DEBUG **/
//        DbManager().reInitMasterPassword()
//        _manager.reinitUserDefaultValue(forKey: Settings().USER_EMAIL_KEY)
        
        // Set the font for title
        ui_mesfacturesTextField.font = UIFont(name: "Abuget", size: 100)
        ui_mesfacturesTextField.text = "MyFactures"
//        setupCustomFont()
        // Hide 'createNewPasswordButton' if a user password exists in the iPhone Keychain
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) == true {
            showConnexionFields(false)
            unlockWithBiometrics()
        } else {
            showConnexionFields(true)
        }
    }

    private func setupCustomFont() {
        guard let customFont = UIFont(name: "Avenir", size: 20) else {
            fatalError("Failed to load the 'Avenir' font. Make sure the font file is included in the project and the font name is spelled correctly.")
        }
    
        ui_passwordTextField.font = UIFontMetrics.default.scaledFont(for: customFont)
        ui_passwordTextField.adjustsFontForContentSizeCategory = true
        ui_lostPasswordButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: customFont)
        ui_lostPasswordButton.titleLabel?.adjustsFontForContentSizeCategory = true
        ui_connexionButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: customFont)
        ui_connexionButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    private func unlockWithBiometrics () {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReasonText, reply: { (isOwnerConfirmed, authError) in
                /**
                    Going back from secondary traitment to firt traitment /
                    Revenir à l'éxécution du code au premier plan après que le traitement en arrière plan (Identifiaction empreinte ou visage) soit effectuée
                 **/
                DispatchQueue.main.async {
                     /** Unlock application **/
                    if isOwnerConfirmed == true {
                        self.unlock()
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
        } else {
            print("device already unlocked")
        }
    }
    
    private func showPasswordField () {
        ui_passwordTextField.isHidden = false
        ui_lostPasswordButton.isHidden = false
        ui_connexionButton.isHidden = false
    }

    func showConnexionFields(_ value: Bool) {
        if value {
            ui_passwordTextField.becomeFirstResponder()
            ui_passwordTextField.text = ""
            
            // Set padding for password textField
            ui_passwordTextField.setPadding()
            ui_passwordTextField.setRadius()
            
            // Set radius for connexion button
            ui_connexionButton.layer.cornerRadius = 5
            
            // Delegation for password textField to have access to textfieldShouldReturn function
            self.ui_passwordTextField.delegate = self
        } else {
            ui_passwordTextField.isHidden = true
            ui_lostPasswordButton.isHidden = true
            ui_connexionButton.isHidden = true
        }
    }
    
    func displayGroupTableViewController () {
        ui_passwordTextField.resignFirstResponder()
        Manager.dismissVC(thisViewController: self, withTransition: .crossDissolve, animated: true)
    }
    
    func displayAddNewInvoiceVC() {
        let addNewInvoiceStoryboard = UIStoryboard(name: "AddNewInvoiceViewController", bundle: .main)
        if let addNewInvoiceVC = addNewInvoiceStoryboard.instantiateViewController(withIdentifier: "AddNewInvoiceViewController") as? AddNewInvoiceViewController {
            addNewInvoiceVC._ptManager = DbManager().getDb()
            addNewInvoiceVC._ptYear = DbManager().getDb()?.getYear(atIndex: 0)
            addNewInvoiceVC._fromOtherApp = true
            addNewInvoiceVC._ptLoginVC = self
            addNewInvoiceVC._ptPickedDocument = UserDefaults.standard.url(forKey: UserDefaults.keys.fileFromOtherAppUrl.rawValue)
            addNewInvoiceVC.modalTransitionStyle = .crossDissolve
            present(addNewInvoiceVC, animated: false, completion: nil)
        }
    }
    
    private func showAlertMessage (_ errorMessage: String) {
        let alertBox = UIAlertController(title: alertErrorText, message: errorMessage, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
            self.showPasswordField()
        }))
    }
    
    private func unlock() {
        let savedApplicationState = UserDefaults.standard.bool(forKey: UserDefaults.keys.savedApplicationState.rawValue)
        let fromOtherApp = UserDefaults.standard.bool(forKey: UserDefaults.keys.fromOtherApp.rawValue)
        // If application returning from background, just dismiss the loginScreen
        // Else show groupScreen
        if savedApplicationState {
            UserDefaults.standard.set(false, forKey: UserDefaults.keys.savedApplicationState.rawValue)
            if fromOtherApp {
                UserDefaults.standard.set(false, forKey: UserDefaults.keys.fromOtherApp.rawValue)
                self.displayAddNewInvoiceVC()
            } else {
                self.displayGroupTableViewController()
            }
        } else {
            self.displayGroupTableViewController()
        }
    }
    
    @IBAction func unlockWithPassword(_ sender: Any) {
        if let typedPassword = ui_passwordTextField.text,
            let storedPassword = DbManager().getMasterPassword() {
            if typedPassword == storedPassword {
                unlock()
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

