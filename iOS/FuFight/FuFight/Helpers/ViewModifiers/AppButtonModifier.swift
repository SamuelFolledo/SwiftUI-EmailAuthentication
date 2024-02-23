//
//  AppButtonModifier.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

enum ViewType {
    case primary
    case secondary
    case tertiary
    case system
    ///Button that will not have borders
    case destructive

    var color: UIColor {
        switch self {
        case .primary:
            return .label
        case .secondary:
            return .systemGreen
        case .tertiary:
            return .systemBackground
        case .system:
            return .systemBlue
        case .destructive:
            return .systemRed
        }
    }
}

extension View {
    ///Create an app's button
    func appButton(_ type: ViewType, isBordered: Bool = false) -> some View {
        self.modifier(AppButtonModifier(type, isBordered: isBordered))
    }
}

struct AppButtonModifier: ViewModifier {
    var viewType: ViewType
    var isBordered: Bool

    let disabledColor: UIColor = .systemGray
    @Environment(\.isEnabled) private var isEnabled: Bool

    init(_ viewType: ViewType, isBordered: Bool) {
        self.viewType = viewType
        self.isBordered = isBordered
    }

    func body(content: Content) -> some View {
        Button(action: {}) {
            HStack {
                Spacer()

                content
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .padding()
                    .background(background)
                    .foregroundColor(
                        Color(uiColor: foregroundColor))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                Color(uiColor: isEnabled ? viewType.color : disabledColor),
                                lineWidth: 2)
                    )
                    .opacity(isEnabled ? 1 : 0.8)
                Spacer()
            }
        }
    }

    var background: some View {
        if isEnabled {
            Color(uiColor: isBordered ? .clear : viewType.color)
        } else {
            Color(uiColor: isBordered ? .clear : disabledColor)
        }
    }
    var foregroundColor: UIColor {
        if viewType == .tertiary {
            return .label
        } else {
            return isEnabled ? (isBordered ? viewType.color : .systemBackground) : (isBordered ? .clear : .label)
        }
    }
}

#Preview {
    VStack {
        Button("Primary", action: {})
            .appButton(.primary)

        Button("Primary Bordered", action: {})
            .appButton(.primary, isBordered: true)

        Button("Secondary", action: {})
            .appButton(.secondary)

        Button("Secondary", action: {})
            .appButton(.secondary, isBordered: true)

        Button("Tertiary", action: {})
            .appButton(.tertiary)

        Button("Tertiary Bordered", action: {})
            .appButton(.tertiary, isBordered: true)

        Button("System", action: {})
            .appButton(.system)

        Button("System", action: {})
            .appButton(.system, isBordered: true)

        Button("Destructive", action: {})
            .appButton(.destructive)

        Button("Destructive Bordered", action: {})
            .appButton(.destructive, isBordered: true)

        Button("Primary Disabled", action: {})
            .appButton(.primary)
            .disabled(true)
        Button("Destructive Disabled", action: {})
            .appButton(.destructive)
            .disabled(true)
    }
    .preferredColorScheme(.light)
}
