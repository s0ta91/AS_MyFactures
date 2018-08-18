//
//  UserInfosViewController.swift
//  MyFactures
//
//  Created by Sébastien on 18/08/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class UserInfosViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    
    //MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmailAddress()
    }

    //MARK: Actions
    @IBAction func confirmEmailAddress(_ sender: UIButton) {
        if let newEmailAddress = emailAddressTextField.text,
            newEmailAddress.isValidEmail {
            UserDefaults.standard.set(newEmailAddress, forKey: Settings().USER_EMAIL_KEY)
        } else {
            Alert.message(title: "Erreur", message: "L'addresse entrée n'est pas valide", vc: self)
        }
        Alert.message(title: "Modification enregistrée", message: "", vc: self)
    }
}

extension UserInfosViewController {
    private func setupEmailAddress() {
        let emailAddress = UserDefaults.standard.string(forKey: Settings().USER_EMAIL_KEY)
        emailAddressTextField.text = emailAddress
    }
}
