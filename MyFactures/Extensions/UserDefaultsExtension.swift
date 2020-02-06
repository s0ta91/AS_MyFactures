//
//  UserDefaultsExtension.swift
//  MyFactures
//
//  Created by Sébastien on 20/07/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum keys: String {
        case savedApplicationState = "savedApplicationState"
        case fromOtherApp = "fromOtherApp"
        case fileFromOtherAppUrl = "fileFromOtherAppUrl"
        case userEmail = "USER_EMAIL"
        case isDarkMode = "isDarkMode"
        case migrationDone = "false"
    }
}
