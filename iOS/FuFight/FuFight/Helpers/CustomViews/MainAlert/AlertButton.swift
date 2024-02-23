//
//  AlertButton.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

enum AlertButtonType {
    case cancel, ok, custom

    var title: LocalizedStringKey {
        switch self {
        case .cancel:
            return "Cancel"
        case .ok:
            return "Ok"
        case .custom:
            return ""
        }
    }

    var bgColor: UIColor {
        switch self {
        case .cancel:
            return .systemBackground
        case .ok:
            return .systemBlue
        case .custom:
            return .clear
        }
    }

    var textColor: UIColor {
        switch self {
        case .cancel:
            return .systemRed
        case .ok:
            return .systemBackground
        case .custom:
            return .systemBlue
        }
    }
}

struct AlertButton: View {
    // MARK: - Value
    // MARK: Public
    var type: AlertButtonType?
    let title: LocalizedStringKey
    let textColor: UIColor
    let bgColor: UIColor
    let isBordered: Bool
    var action: (() -> Void)? = nil

    init(title: LocalizedStringKey, textColor: UIColor = .systemBackground, bgColor: UIColor = .systemBackground, isBordered: Bool = true, action: (() -> Void)? = nil) {
        self.title = title
        self.textColor = textColor
        self.bgColor = bgColor
        self.isBordered = isBordered
        self.action = action
    }

    init(type: AlertButtonType, textColor: UIColor? = nil, bgColor: UIColor? = nil, isBordered: Bool = true, action: (() -> Void)? = nil) {
        self.type = type
        self.title = type.title
        self.textColor = type.textColor
        self.bgColor = type.bgColor
        self.isBordered = isBordered
        self.action = action
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                Spacer()

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(uiColor: textColor))
                    .contentShape(Rectangle())

                Spacer()
            }
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: isBordered ? .label : bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(uiColor: isBordered ? bgColor : .label), lineWidth: 2)
                )
        )
        .cornerRadius(15)
    }
}
