//
//  Rectangle.swift
//  Bitcore
//
//  Created by ROSHii on 7/18/18.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class Circle: UIView {
    
    private let color: UIColor
    
    static let defaultSize: CGFloat = 64.0
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.addEllipse(in: rect)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
