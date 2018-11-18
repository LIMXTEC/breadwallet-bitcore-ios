//
//  UINavigationController+BRAdditions.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2016-11-29.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit

extension UINavigationController {

    func setDefaultStyle() {
        setClearNavbar()
        navigationBar.tintColor = .mediumGray
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setWhiteStyle() {
        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.customBold(size: 16.0)
        ]
    }
    
    func setGrayStyle() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .whiteBackground
        navigationBar.tintColor = .mediumGray
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.customBold(size: 16.0)
        ]
    }

    func setClearNavbar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    func setNormalNavbar() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }
}
