//
//  ViewController.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ui_mesfacturesTextField: UITextField!
    @IBOutlet weak var ui_passwordTextField: UITextField!
    @IBOutlet weak var ui_resetPasswordButton: UIButton!
    @IBOutlet weak var ui_connexionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** DEBUG **/
//         DbManager().reInitMasterPassword()
        
        // Set the font for title
        ui_mesfacturesTextField.font = UIFont(name: "Abuget", size: 100)
        ui_mesfacturesTextField.text = "MyFactures"
        
        // Hide 'createNewPasswordButton' if a user password exists in the iPhone Keychain
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) == true {
            ui_passwordTextField.isHidden = true
            ui_resetPasswordButton.isHidden = true
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    private func unlockWithBiometrics () {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Déverouiller MyFactures", reply: { (isOwnerConfirmed, authError) in
                /**
                    Going back from secondary traitment to firt traitment /
                    Revenir à l'éxécution du code a premier plan après que le traitement en arrière plan (Identifiaction empreinte ou visage) soit effectuée
                 **/
                DispatchQueue.main.async {
                     /** Unlock application and show group screen **/
                    if isOwnerConfirmed == true {
                        self.displayGroupTableViewController()
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
        ui_resetPasswordButton.isHidden = false
        ui_connexionButton.isHidden = false
    }

    func displayGroupTableViewController () {
        if let GroupTableVC = storyboard?.instantiateViewController(withIdentifier: "NavGroupContoller") {
            GroupTableVC.modalTransitionStyle = .crossDissolve
            present(GroupTableVC, animated: true, completion: nil)
        }
    }
    
    private func showAlertMessage (_ errorMessage: String) {
        let alertBox = UIAlertController(title: "Une erreur est survenue", message: errorMessage, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
            self.showPasswordField()
        }))
    }
    
    func shakeTextField() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: ui_passwordTextField.center.x - 4, y: ui_passwordTextField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: ui_passwordTextField.center.x + 4, y: ui_passwordTextField.center.y))
        
        ui_passwordTextField.layer.add(animation, forKey: "position")
    }
    
    @IBAction func unlockWithPassword(_ sender: Any) {
        if let typedPassword = ui_passwordTextField.text,
            let storedPassword = DbManager().getMasterPassword() {
            if typedPassword == storedPassword {
                displayGroupTableViewController()
            }else {
                shakeTextField()
            }
        }
    }
}

