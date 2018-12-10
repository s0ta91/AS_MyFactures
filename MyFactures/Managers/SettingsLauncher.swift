//
//  SettingsLauncher.swift
//  YoutubeCloneApp
//
//  Created by Sébastien on 22/06/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SettingsLauncher: NSObject {
    
    let CELL_ID = "cellId"
    let CELL_HEIGHT: CGFloat = 50
    
    let _blackView = UIView()
    var _homeController: GroupViewController?
    
    let _settings: [Setting] = {
        let informations = Setting(name: .informations, imageName: "settings_grey")
        let resetPassword = Setting(name: .resetPassword, imageName: "privacy")
        let feedback = Setting(name: .feedback, imageName: "contact")
        let about = Setting(name: .about, imageName: "about")
        let cancel = Setting(name: .cancel, imageName: "cancel")
//        return [settings, terms, feedback, help, switchAccount, cancel]
        return [informations, resetPassword, feedback, about, cancel]
    }()
    
    
    let _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isScrollEnabled = false
        return cv
    }()
    
    func showSettings() {
        if let window = UIApplication.shared.keyWindow {
            _blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            _blackView.frame = window.frame
            _blackView.alpha = 0
            
            _blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss(withSetting:)) ))
            window.addSubview(_blackView)
            
            window.addSubview(_collectionView)
            let height: CGFloat = CGFloat(_settings.count) * CELL_HEIGHT
            let y = window.frame.height - height
            _collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self._blackView.alpha = 1
                self._collectionView.frame = CGRect(x: 0, y: y, width: self._collectionView.frame.width, height: height)
            }, completion: nil)
            
        }
    }
    
    @objc func handleDismiss(withSetting setting: Setting) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self._blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self._collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self._collectionView.frame.width, height: self._collectionView.frame.height)
            }
        }) { (completed: Bool) in
            if setting.name != .cancel  {
                self._homeController?.showController(forSetting: setting)
            }
        }
    }
    
    override init() {
        super.init()
        
        _collectionView.dataSource = self
        _collectionView.delegate = self
        
        _collectionView.register(SettingCollectionViewCell.self, forCellWithReuseIdentifier: CELL_ID)
    }
}

extension SettingsLauncher: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! SettingCollectionViewCell
        cell._settings = _settings[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = self._settings[indexPath.item]
        handleDismiss(withSetting: setting)
    }
}

extension SettingsLauncher: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _collectionView.frame.width, height: CELL_HEIGHT)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
