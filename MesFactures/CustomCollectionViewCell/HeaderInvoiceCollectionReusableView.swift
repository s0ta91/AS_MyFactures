//
//  HeaderInvoiceCollectionReusableView.swift
//  MesFactures
//
//  Created by Sébastien on 12/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class HeaderInvoiceCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var ui_headerDateLabel: UILabel!
    @IBOutlet weak var ui_totalMonthAmountLabel: UILabel!
    
    var _ptManager: Manager?
    
    func setValuesForHeader (_ date: String, _ totalMonthAmount: String) {
        ui_headerDateLabel.text = date
        ui_totalMonthAmountLabel.text = totalMonthAmount
        
        if let _manager = _ptManager {
            _manager.convertToCurrencyNumber(forLabel: ui_totalMonthAmountLabel)
        }
    }
}
