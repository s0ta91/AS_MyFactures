//
//  Setting.swift
//  MyFactures
//
//  Created by Sébastien Constant on 05/12/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

enum SettingName: String {
    case cancel = "Cancel"
    case informations = "Your informations"
    case resetPassword = "Reset your password"
    case feedback = "Contact / report a bug"
    case about = "About"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

class Setting: NSObject {
    let name: SettingName
    let imageName: String
    
    init(name: SettingName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
