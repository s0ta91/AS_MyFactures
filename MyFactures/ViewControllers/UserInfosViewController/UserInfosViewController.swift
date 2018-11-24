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
    
    //MARK: NSLocalized text
    let errorTitle = NSLocalizedString("Error", comment: "")
    let errorMessage = NSLocalizedString("The email address is not valid", comment: "")
    let confirmTitle = NSLocalizedString("Changes has been saved", comment: "")
    
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
            Alert.message(title: errorTitle, message: errorMessage, vc: self)
        }
        Alert.message(title: confirmTitle, message: "", vc: self)
    }
}

extension UserInfosViewController {
    private func setupEmailAddress() {
        let emailAddress = UserDefaults.standard.string(forKey: Settings().USER_EMAIL_KEY)
        emailAddressTextField.text = emailAddress
    }
}
