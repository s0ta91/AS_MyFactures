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
    @IBOutlet weak var ui_createNewPasswordButton: UIButton!
    @IBOutlet weak var ui_connexionButton: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /** DEBUG **/
//        DbManager().reInitMasterPassword()
        
        /** Set the font for title **/
        ui_mesfacturesTextField.font = UIFont(name: "Abuget", size: 100)
        
        /** Hide 'createNewPasswordButton' if a user password exists in the iPhone Keychain  **/
        showHideCreateNewPasswordButton()
        
        /** Delegation for password textField **/
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
                if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) == true {
                    ui_passwordTextField.isHidden = true
                    ui_connexionButton.isHidden = true
                    unlockWithBiometrics()
                }
            }else {
                ui_createNewPasswordButton.isHidden = false
            }
        }
    }
    
    private func unlockWithBiometrics () {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)  {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Déverouiller MesFactures", reply: { (isOwnerConfirmed, authError) in
                /**
                    Going back from secondary traitment to firt traitment /
                    Revenir à l'éxécution du code a premier plan après que le traitement en arrière plan (Identifiaction empreinte ou visage) soit effectuée
                 **/
                DispatchQueue.main.async {
                     /** Unlock application and show group screnn **/
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
                ui_passwordTextField.text = ""
            }
        }
    }
}

