//
//  MainAlertModifier.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

struct MainAlertModifier {

    // MARK: - Value
    // MARK: Private
    @Binding private var isPresented: Bool

    // MARK: Private
    private let title: String
    private let message: String
    private let dismissButton: AlertButton?
    private let primaryButton: AlertButton?
    private let secondaryButton: AlertButton?
}


extension MainAlertModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                MainAlert(title: title, message: message, dismissButton: dismissButton, primaryButton: primaryButton, secondaryButton: secondaryButton)
            }
    }
}

extension MainAlertModifier {

    init(title: String = "", message: String = "", dismissButton: AlertButton, isPresented: Binding<Bool>) {
        self.title         = title
        self.message       = message
        self.dismissButton = dismissButton
        self.primaryButton   = nil
        self.secondaryButton = nil
        _isPresented = isPresented
    }

    init(title: String = "", message: String = "", primaryButton: AlertButton, secondaryButton: AlertButton, isPresented: Binding<Bool>) {
        self.title           = title
        self.message         = message
        self.primaryButton   = primaryButton
        self.secondaryButton = secondaryButton
        self.dismissButton = nil
        _isPresented = isPresented
    }
}
