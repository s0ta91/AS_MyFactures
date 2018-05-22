//
//  SelectYearTableViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 09/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SelectYearTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_yearLabel: UILabel!
    @IBOutlet weak var ui_numberOfGroupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setValues(_ year: String, _ numberOfGroup: String) {
        
        ui_yearLabel.text = year
        ui_numberOfGroupLabel.text = numberOfGroup
    }

}
