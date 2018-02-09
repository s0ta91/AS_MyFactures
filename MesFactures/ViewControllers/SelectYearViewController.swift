//
//  SelectYearViewController.swift
//  MesFactures
//
//  Created by Sébastien on 09/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SelectYearViewController: UIViewController {

    @IBOutlet weak var ui_selectYearTableView: UITableView!
    var _manager: Manager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_selectYearTableView.dataSource = self
        ui_selectYearTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeSelectYearVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension SelectYearViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _manager.getyearsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_yearSelection = tableView.dequeueReusableCell(withIdentifier: "cell_yearSelection", for: indexPath)
        if let year = _manager.getYear(atIndex: indexPath.row) {
            let yearString = String(describing: year.year)
            cell_yearSelection.textLabel?.text = yearString
            if year.selected == true {
//                print("\(yearString) checkmark")
                cell_yearSelection.accessoryType = .checkmark
            }else {
//                print("\(yearString) none")
                cell_yearSelection.accessoryType = .none
            }
        }
        return cell_yearSelection
    }
}

extension SelectYearViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedYear = _manager.getYear(atIndex: indexPath.row) {
            _manager.setSelectedYear(forYear: selectedYear)
            ui_selectYearTableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
    }
}
