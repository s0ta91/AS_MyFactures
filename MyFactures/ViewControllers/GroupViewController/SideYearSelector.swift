//
//  SideYearSelector.swift
//  MyFactures
//
//  Created by Sébastien Constant on 11/12/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit

class SideYearSelector: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sideView: UIView!
    
    @IBOutlet weak var sideYearSelectorConstraint: NSLayoutConstraint!
    
    var xPosition: CGFloat = -250
    var newAnchorConstant: CGFloat = -250
    var gestureWasDraggingFromLeftToRight = false
    var gestureWasDraggingFromRightToLeft = false
    var isSideYearSelectorOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.leftAnchor.constraint(equalTo: sideView.rightAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.addConstraint(withFormat: "H:[v0(\(view.frame.width))]", views: mainView)
        NotificationCenter.default.addObserver(self, selector: #selector(showSideYearSelector), name: NSNotification.Name("showHideSideYearSelector"), object: nil)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func showSideYearSelector() {
        if isSideYearSelectorOpen {
            self.sideYearSelectorConstraint.constant = -250
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.sideYearSelectorConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        isSideYearSelectorOpen = !isSideYearSelectorOpen
    }
}

extension SideYearSelector: UIGestureRecognizerDelegate {
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        let gestureIsDraggingFromRightToLeft = (recognizer.velocity(in: view).x < 0)
        switch recognizer.state {
            
        case .began:
            xPosition = newAnchorConstant
            NotificationCenter.default.post(name: NSNotification.Name("sideAnchorChangeHasBegan"), object: nil)
            
        case .changed:
            if gestureIsDraggingFromLeftToRight {
                gestureWasDraggingFromRightToLeft = false
                gestureWasDraggingFromLeftToRight = true
                newAnchorConstant = xPosition + recognizer.translation(in: view).x
                print(newAnchorConstant)
                if newAnchorConstant <= 0 {
                    self.sideYearSelectorConstraint.constant = newAnchorConstant
                }
            } else if gestureIsDraggingFromRightToLeft {
                gestureWasDraggingFromRightToLeft = true
                gestureWasDraggingFromLeftToRight = false
                newAnchorConstant = xPosition + recognizer.translation(in: view).x
                if newAnchorConstant >= -250 {
                    self.sideYearSelectorConstraint.constant = newAnchorConstant
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name("sideAnchorIsChanging"), object: nil, userInfo: ["sideAnchorValue": newAnchorConstant])
            
        case .ended:
            let oneThird: CGFloat = -200
            
            
            if gestureWasDraggingFromLeftToRight {
                if newAnchorConstant >= oneThird {
                    newAnchorConstant = 0
                    isSideYearSelectorOpen = true
                } else {
                    newAnchorConstant = -250
                    isSideYearSelectorOpen = false
                }
            } else if gestureWasDraggingFromRightToLeft {
                if newAnchorConstant < 0 {
                    newAnchorConstant = -250
                    isSideYearSelectorOpen = false
                } else {
                    newAnchorConstant = 0
                    isSideYearSelectorOpen = true
                }
            }
        
            self.sideYearSelectorConstraint.constant = newAnchorConstant
            NotificationCenter.default.post(name: NSNotification.Name("sideAnchorChangeEnded"), object: nil, userInfo: ["isSideYearSelectorOpen": self.isSideYearSelectorOpen])
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                
            }
            
        default:
            break
        }
    }
}
