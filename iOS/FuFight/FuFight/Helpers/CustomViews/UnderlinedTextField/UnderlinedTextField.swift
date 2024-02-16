//
//  UnderlinedTextField.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//
//  inspired by Stackoverflow's post https://stackoverflow.com/questions/31107994/how-to-only-show-bottom-border-of-uitextfield-in-swift/31108018

import UIKit

class UnderlinedTextField: UITextField {
    private let defaultUnderlineColor = UIColor.black
    private let bottomLine = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        borderStyle = .none
        contentVerticalAlignment = .center
        clearButtonMode = .unlessEditing
        font = UIFont.boldSystemFont(ofSize: 18)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = defaultUnderlineColor
        self.addSubview(bottomLine)
        bottomLine.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    public func setUnderlineColor(color: UIColor = .red) {
        bottomLine.backgroundColor = color
    }

    public func setDefaultUnderlineColor() {
        bottomLine.backgroundColor = defaultUnderlineColor
    }
}

extension UnderlinedTextField {

    func hasError() {
        self.setUnderlineColor(color: .systemRed)
    }

    func hasNoError() {
        self.setDefaultUnderlineColor()
    }
}
