//
//  UIBarButtonItem+Additions.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-04-24.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static var negativePadding: UIBarButtonItem {
        let padding = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        padding.width = -16.0
        return padding
    }
}
