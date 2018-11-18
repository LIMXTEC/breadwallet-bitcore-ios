//
//  MenuCell.swift
//  bitcorewallet
//
//  Created by Ehsan Rezaie on 2018-01-31.
//  Copyright © 2018 breadwallet LLC. All rights reserved.
//

import UIKit

class MenuCell : UITableViewCell {
    
    static let cellIdentifier = "MenuCell"
    
    private let container = UIView(color: .grayBackground)
    private let iconView = UIImageView()
    private let label = UILabel(font: .customBody(size: 16.0), color: .darkGray)
    private let arrow = UIImageView(image: #imageLiteral(resourceName: "RightArrow").withRenderingMode(.alwaysTemplate))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func set(title: String, icon: UIImage) {
        label.text = title
        iconView.image = icon.withRenderingMode(.alwaysTemplate)
    }
    
    private func setup() {
        addSubviews()
        addConstraints()
        setupStyle()
    }
    
    private func addSubviews() {
        contentView.addSubview(container)
        container.addSubview(iconView)
        container.addSubview(label)
        container.addSubview(arrow)
    }
    
    private func addConstraints() {
        container.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1],
                                                           left: C.padding[2],
                                                           bottom: 0.0,
                                                           right: -C.padding[2]))
        iconView.constrain([
            iconView.heightAnchor.constraint(equalToConstant: 16.0),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: C.padding[2]),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        
        label.constrain([
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: C.padding[1]),
            label.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: C.padding[1]),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        
        arrow.constrain([
            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -C.padding[2]),
            arrow.widthAnchor.constraint(equalToConstant: 3.5),
            arrow.heightAnchor.constraint(equalToConstant: 6.0),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
    }
    
    private func setupStyle() {
        selectionStyle = .none
        container.layer.cornerRadius = C.Sizes.roundedCornerRadius
        container.clipsToBounds = true
        
        contentView.backgroundColor = .whiteBackground
        iconView.tintColor = .darkGray
        arrow.tintColor = .darkGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
