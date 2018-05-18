//
//  ResetPasswordViewController.swift
//  MesFactures
//
//  Created by Sébastien on 27/03/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_oldPasswordTextField: UITextField!
    @IBOutlet weak var ui_newPasswordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!

    // MARK: - Global Variables
    let dbManager = DbManager()

    // MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideMessageLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private functions
    private func hideMessageLabel() {
        messageLabel.isHidden = true
    }
    private func unHideMessageLabel() {
        messageLabel.isHidden = false
    }

    // MARK: - Actions

    @IBAction func resetPassword(_ sender: UIButton) {
        //TODO: Check if textFields are not empty
        guard let oldPassword = ui_oldPasswordTextField.text else { return print("textField 'ui_oldPasswordTextField' is empty") }
        guard let newPassword = ui_newPasswordTextField.text else { return print("textField 'ui_newPasswordTextField' is empty") }
        if oldPassword.count > 0 && newPassword.count > 0 {
            hideMessageLabel()
            //TODO: Change the password
            if let oldPasswordInKeychain = dbManager.getMasterPassword() {
                if oldPassword == oldPasswordInKeychain {
                    dbManager.reInitMasterPassword()
                    dbManager.saveMasterPassword(newPassword)

                    //TODO: Confirmation Message then Dismiss the screen
                    let confirmationAlert = UIAlertController(title: "Le mot de passe a été changé", message: nil, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    confirmationAlert.addAction(alertAction)
                    present(confirmationAlert, animated: true)
                } else {
                    //TODO: Else, show a error message
                    let alert = UIAlertController(title: "Erreur!", message: "Le mot de passe actuel n'est pas correcte. Veuillez réessayer.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ré-essayer", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    present(alert, animated: true, completion: nil)

                    print("Old password entered does not match the passord in KeyChain")
                }

            } else {
                //TODO: If no password in keychain show an error message
                messageLabel.text = "Error! - No password found in keychain"
                unHideMessageLabel()
            }
        } else {
            messageLabel.text = "Les champs ne peuvent être vides. Veuillez les compléter."
            unHideMessageLabel()
        }

    }

    @IBAction func cancelResetPasswordVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
