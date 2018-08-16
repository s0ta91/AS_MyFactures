//
//  LostPasswordViewController.swift
//  MyFactures
//
//  Created by Sébastien on 17/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class VerifyPasswordViewController: UIViewController {

    
    @IBOutlet weak var ui_messageTextView: UITextView!
    @IBOutlet weak var ui_codeTextField: UITextField!
    @IBOutlet weak var ui_verifyEmailCodeButton: UIButton!
    
    private var _manager: Manager {
        if let database =  DbManager().getDb() {
            return database
        }else {
            fatalError("Database doesn't exists")
        }
    }
    
    var randomCode: String?
    var emailAdress: String!
    var password: String!
    
    //TODO: Localized text
    let messageText = NSLocalizedString("Please check your emails and enter the confirmation code :", comment: "")
    let confirmationTitle = NSLocalizedString("Thank you !", comment: "")
    let confirmationMessage = NSLocalizedString("Email address is confirmed", comment: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_verifyEmailCodeButton.layer.cornerRadius = 5.0
        ui_messageTextView.text = messageText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func codeIsValid() -> Bool {
        return ui_codeTextField.text == randomCode
    }
    
    func showConfirmationAlertMessage () {
        let alertMessageSent = UIAlertController(title: confirmationTitle, message: confirmationMessage, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self._manager.createUser(with: self.password, andEmail: self.emailAdress)
            self.displayGroupTableViewController()
        }
        
        alertMessageSent.addAction(confirmAction)
        present(alertMessageSent, animated: true, completion: nil)
    }
    
    func displayGroupTableViewController () {
        let storyboard = UIStoryboard(name: "GroupViewController", bundle: .main)
        let GroupTableVC = storyboard.instantiateViewController(withIdentifier: "NavGroupContoller")
        GroupTableVC.modalTransitionStyle = .crossDissolve
        present(GroupTableVC, animated: true, completion: nil)
    }
    
    
    @IBAction func verifyEmailCode(_ sender: UIButton) {
        if codeIsValid() {
            showConfirmationAlertMessage()
        } else {
            //TODO: Faire vibrer le champs texte
            _manager.shake(ui_codeTextField)
        }
    }
}
