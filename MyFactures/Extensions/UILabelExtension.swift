//
//  UILabelExtension.swift
//  MyFactures
//
//  Created by Sébastien on 21/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

extension UILabel {
    
    func convertToCurrencyNumber() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.locale = NSLocale.autoupdatingCurrent
        // currencyFormatter.locale = Locale(identifier: "fr-FR")
        currencyFormatter.decimalSeparator = "."
        
        if let amountString = self.text,
            let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                self.text = numberToCurrencyType
            }
        }
    }
}
