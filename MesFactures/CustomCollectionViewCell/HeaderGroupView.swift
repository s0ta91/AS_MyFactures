//
//  HeaderGroupCollectionViewCell.swift
//  MesFactures
//
//  Created by Sébastien on 05/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class HeaderGroupView: UICollectionReusableView {

    @IBOutlet weak var headerViewLabel: UILabel!

    func setYear (withYear year: String, fontSize: CGFloat) {
        headerViewLabel.text = year
        setFontSize(with: fontSize)
    }
    func setFontSize (with fontSize: CGFloat) {
        headerViewLabel.font = headerViewLabel.font.withSize(fontSize)
    }
}
