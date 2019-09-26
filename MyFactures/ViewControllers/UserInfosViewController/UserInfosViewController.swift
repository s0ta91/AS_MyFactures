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
    let discardChangesActionTitle = NSLocalizedString("Discard Changes", comment: "")
    let save = NSLocalizedString("Save", comment: "")
    let cancel = NSLocalizedString("Cancel", comment: "")
    
    var hasChanges: Bool {
        editedText != originalText
    }
    var originalText: String?  {
        didSet {
            editedText = originalText
        }
    }
    var editedText: String? = "" {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddressTextField.delegate = self
        print(#function)
        setupEmailAddress()
    }
    
    override func viewWillLayoutSubviews() {
        
        emailAddressTextField.text = editedText
        print("hasChanges: \(hasChanges)")
        let hasChanges = self.hasChanges
        if #available(iOS 13, *) {
            isModalInPresentation = hasChanges
        }
        
    }
    
    
    // MARK: - Private
    private func setupEmailAddress() {
            let emailAddress = UserDefaults.standard.string(forKey: Settings().USER_EMAIL_KEY)
            originalText = emailAddress
            emailAddressTextField.becomeFirstResponder()
        }
    
    fileprivate func confirmCancel() {
        
        // Present an action sheet, which in a regular width environment appears as a popover
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: discardChangesActionTitle, style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        
        let saveAction = UIAlertAction(title: save, style: .default) { _ in
            self.controlEmailAndSave()
        }
        
        alert.addAction(saveAction)
        
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func controlEmailAndSave() {
        if let newEmailAddress = emailAddressTextField.text,
            newEmailAddress.isValidEmail {
            UserDefaults.standard.set(newEmailAddress, forKey: Settings().USER_EMAIL_KEY)
            dismiss(animated: true)
        } else {
            Alert.message(title: errorTitle, message: errorMessage, vc: self)
        }
    }

    //MARK: Actions
    @IBAction func confirmEmailAddress(_ sender: UIButton) {
        controlEmailAndSave()
    }
}

extension UserInfosViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("didAttemptToDismiss in VC")
        confirmCancel()
    }
}

extension UserInfosViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        editedText = textField.text
    }
    
}
