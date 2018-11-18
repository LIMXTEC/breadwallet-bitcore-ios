//
//  UIFont+BRWAdditions.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2016-10-27.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit

extension UIFont {
    static var header: UIFont {
        guard let font = UIFont(name: "CircularPro-Bold", size: 17.0) else { return UIFont.preferredFont(forTextStyle: .headline) }
        return font
    }
    static func customBold(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "CircularPro-Bold", size: size) else { return UIFont.preferredFont(forTextStyle: .headline) }
        return font
    }
    static func customBody(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "CircularPro-Book", size: size) else { return UIFont.preferredFont(forTextStyle: .subheadline) }
        return font
    }
    static func customMedium(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "CircularPro-Medium", size: size) else { return UIFont.preferredFont(forTextStyle: .body) }
        return font
    }

    static var regularAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont.customBody(size: 14.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkText
        ]
    }

    static var boldAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: UIFont.customBold(size: 14.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkText
        ]
    }
}
