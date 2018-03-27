//
//  SettingsViewController.swift
//  MesFactures
//
//  Created by Sébastien on 27/03/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Actions
    @IBAction func cancelSettingsVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_resetPassword", for: indexPath)
        cell.textLabel?.text = "Reset Password"
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
}
