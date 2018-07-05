//
//  TextField.swift
//  MyFactures
//
//  Created by Sébastien on 14/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPadding() {
        let padding = CGRect(x: 0, y: 0, width: 15, height: self.frame.height)
        let paddingView = UIView(frame: padding)
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRadius() {
        self.layer.cornerRadius = 5
    }
    
    func convertToCurrencyNumber() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.locale = NSLocale.autoupdatingCurrent
        currencyFormatter.decimalSeparator = "."
        
        if let amountString = self.text?.replacingOccurrences(of: ",", with: "."),
        let amountDouble = Double(amountString) {
            let amountNumber = NSNumber(value: amountDouble)
            if let numberToCurrencyType = currencyFormatter.string(from: amountNumber) {
                self.text = numberToCurrencyType
            }
        }
    }

    func convertFromCurrencyNumber () -> Decimal? {
        guard let text = self.text else { return nil }

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.number(from: text)?.decimalValue
    }
}
