//
//  ManagerCagegoryTableViewController.swift
//  MesFactures
//
//  Created by Sébastien on 21/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class ManagerCagegoryTableViewController: UITableViewController {

    //MARK: - Outlets
    
    
    //MARK: - paththrough Managers/Objects
    var _ptManager: Manager?
    
    //MARK: - Global variable filled with passthrough Managers/objects
    private var _manager: Manager!
    
    //MARK: - Others
    
    
    //MARK: - Controller functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private functions
    private func checkReceivedData () {
        if let recievedManager = _ptManager {
            _manager = recievedManager
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _manager.getCategoryCount()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_category = tableView.dequeueReusableCell(withIdentifier: "cell_category", for: indexPath)
        cell_category.textLabel?.text = _manager.getCategory(atIndex: indexPath.row)?.title
        return cell_category
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
            _manager.removeCategory(atIndex: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 
    
    //MARK: - Actions
    
    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
