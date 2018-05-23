//
// Settings.swift
//  MyFactures
//
//  Created by Sébastien on 17/05/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

class Settings {
    
    // Smtp connexion values
    let hostname = "smtp.gmail.com"
    let emailAdress = "myfacturesapp@gmail.com"
    let emailPassword: String = "SfK.1:LM"
    let port: UInt32 = 465
    
    // UserDefaults Keys
    let USER_EMAIL_KEY = "USER_EMAIL"
}
