//
//  DataExtension.swift
//  MesFactures
//
//  Created by Sébastien on 02/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import Foundation

extension Data {
    init?(countOfRandomData: Int) {
        self.init(count: countOfRandomData)
        let result = self.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, countOfRandomData, $0)
        }
        if result != errSecSuccess {
            return nil
        }
    }
}
