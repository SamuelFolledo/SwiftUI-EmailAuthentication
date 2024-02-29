//
//  View+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/18/24.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension View {
    ///Present alert with a dismiss button
    func alert(title: String = "", message: String = "", dismissButton: AlertButton = AlertButton(title: "ok"), isPresented: Binding<Bool>) -> some View {
        let title   = NSLocalizedString(title, comment: "")
        let message = NSLocalizedString(message, comment: "")
        return modifier(MainAlertModifier(title: title, message: message, dismissButton: dismissButton, isPresented: isPresented))
    }

    ///Present alert with a primary and secondary buttons
    func alert(title: String = "", message: String = "", primaryButton: AlertButton, secondaryButton: AlertButton, isPresented: Binding<Bool>) -> some View {
        let title   = NSLocalizedString(title, comment: "")
        let message = NSLocalizedString(message, comment: "")
        return modifier(MainAlertModifier(title: title, message: message, primaryButton: primaryButton, secondaryButton: secondaryButton, isPresented: isPresented))
    }

    ///alerts with a TextField
    func alert(withText text: Binding<String>, fieldType: FieldType, title: String, primaryButton: AlertButton?, secondaryButton: AlertButton? = AlertButton(type: .cancel), isPresented: Binding<Bool>) -> some View {
        return modifier(MainAlertModifier(withText: text, fieldType: fieldType, title: title, primaryButton: primaryButton, secondaryButton: secondaryButton, isPresented: isPresented))
    }
}
