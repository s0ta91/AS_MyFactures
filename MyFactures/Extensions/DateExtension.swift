//
//  DateExtension.swift
//  MyFactures
//
//  Created by Sébastien on 05/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

extension Date {
    
    var currentMonth: String {
        let strMonth = DateFormatter()
        strMonth.dateFormat = "MMMM"
        strMonth.locale = Locale(identifier: "fr-FR")
        return strMonth.string(from: self).prefix(1).uppercased() + strMonth.string(from: self).dropFirst()
    }
}
