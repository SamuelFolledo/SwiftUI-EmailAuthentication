//
//  MainAlert.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

struct MainAlert: View {

    // MARK: - Value
    // MARK: Public
    let title: String
    let message: String
    let dismissButton: AlertButton?
    let primaryButton: AlertButton?
    let secondaryButton: AlertButton?
    ///Show a TextField if this is not nil
    let fieldType: FieldType?
    @Binding var text: String
    @State var isFieldSecure: Bool = false

    // MARK: Private
    @State private var opacity: CGFloat           = 0
    @State private var backgroundOpacity: CGFloat = 0
    @State private var scale: CGFloat             = 0.001

    @Environment(\.dismiss) private var dismiss

    ///Default initializer
    init(title: String, message: String, dismissButton: AlertButton?, primaryButton: AlertButton?, secondaryButton: AlertButton?) {
        self.title = title
        self.message = message
        self.dismissButton = dismissButton
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        fieldType = nil
        _text = .constant("")
    }

    ///Initializer for alerts with a TextField
    init(withText text: Binding<String>, fieldType: FieldType, title: String, primaryButton: AlertButton?, secondaryButton: AlertButton?) {
        self.fieldType = fieldType
        self.title = title
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        _text = text
        self.message = ""
        self.dismissButton = nil
    }

    // MARK: - View
    // MARK: Public
    var body: some View {
        ZStack {
            dimView

            alertView
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .task {
            animate(isShown: true)
        }
        .onAppear {
            if let fieldType {
                isFieldSecure = fieldType.isSensitive
            }
        }
    }

    // MARK: Private
    private var alertView: some View {
        VStack(spacing: 12) {
            titleView
            messageView
            buttonsView
        }
        .padding([.horizontal, .top], 24)
        .padding(.bottom)
        .frame(width: 320)
        .background(Color.systemBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 12)
    }

    @ViewBuilder
    private var titleView: some View {
        if !title.isEmpty {
            Text(title)
                .font(smallTitleFont)
                .foregroundColor(Color.label)
                .lineSpacing(24 - UIFont.systemFont(ofSize: 18, weight: .bold).lineHeight)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var messageView: some View {
        if let fieldType {
            UnderlinedTextField(type: .constant(fieldType), text: $text, isSecure: $isFieldSecure, showTitle: false)
                .onSubmit {
                    primaryButtonAction()
                }
        } else if !message.isEmpty {
            Text(message)
                .font(.system(size: title.isEmpty ? 18 : 16))
                .foregroundColor(title.isEmpty ? .black : .gray)
                .lineSpacing(24 - UIFont.systemFont(ofSize: title.isEmpty ? 18 : 16).lineHeight)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var buttonsView: some View {
        HStack(spacing: 12) {
            if dismissButton != nil {
                dismissButtonView

            } else if primaryButton != nil, secondaryButton != nil {
                secondaryButtonView
                primaryButtonView
            }
        }
        .padding(.top, 8)
    }

    func primaryButtonAction() {
        if let primaryButton {
            animate(isShown: false) {
                dismiss()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                primaryButton.action?()
            }
        }
    }

    @ViewBuilder
    private var primaryButtonView: some View {
        if let primaryButton {
            if primaryButton.type == .custom {
                AlertButton(title: primaryButton.title, action: primaryButtonAction)
            } else {
                AlertButton(type: primaryButton.type, action: primaryButtonAction)
            }
        }
    }

    @ViewBuilder
    private var secondaryButtonView: some View {
        if let button = secondaryButton {
            let buttonAction = {
                animate(isShown: false) {
                    dismiss()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    button.action?()
                }
            }
            if button.type == .custom {
                AlertButton(title: button.title, action: buttonAction)
            } else {
                AlertButton(type: button.type, action: buttonAction)
            }
        }
    }

    @ViewBuilder
    private var dismissButtonView: some View {
        if let button = dismissButton {
            let buttonAction = {
                animate(isShown: false) {
                    dismiss()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    button.action?()
                }
            }
            if button.type == .custom {
                AlertButton(title: button.title, action: buttonAction)
            } else {
                AlertButton(type: button.type, action: buttonAction)
            }
        }
    }

    private var dimView: some View {
        Color.systemGray
            .opacity(0.55)
            .opacity(backgroundOpacity)
            .onTapGesture {
                animate(isShown: false) {
                    dismiss()
                }
            }
    }


    // MARK: - Function
    // MARK: Private
    private func animate(isShown: Bool, completion: (() -> Void)? = nil) {
        switch isShown {
        case true:
            opacity = 1

            withAnimation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0).delay(0.5)) {
                backgroundOpacity = 1
                scale             = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }

        case false:
            withAnimation(.easeOut(duration: 0.2)) {
                backgroundOpacity = 0
                opacity           = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                completion?()
            }
        }
    }
}

#if DEBUG
struct MainAlert_Previews: PreviewProvider {

    static var previews: some View {
        let showType: Bool = true

        let dismissButton   = AlertButton(title: "Ok")
        let primaryButton   = AlertButton(title: "Ok")
        let secondaryButton = AlertButton(title: "Cancel")

        let dismissButton2   = AlertButton(type: .ok)
        let primaryButton2   = AlertButton(type: .delete)
        let secondaryButton2 = AlertButton(type: .ok)

        let title = "This is your life. Do what you want and do it often."
        let message = """
                    If you don't like something, change it.
                    If you don't like your job, quit.
                    If you don't have enough time, stop watching TV.
                    """

        return VStack {
            if showType {
                MainAlert(title: title, message: message, dismissButton: dismissButton2, primaryButton: nil,           secondaryButton: nil)
                MainAlert(title: title, message: message, dismissButton: nil,           primaryButton: primaryButton2, secondaryButton: secondaryButton2)
            } else {
                MainAlert(title: title, message: message, dismissButton: nil,           primaryButton: nil,           secondaryButton: nil)
                MainAlert(title: title, message: message, dismissButton: dismissButton, primaryButton: nil,           secondaryButton: nil)
                MainAlert(title: title, message: message, dismissButton: nil,           primaryButton: primaryButton, secondaryButton: secondaryButton)
            }
        }
        .previewDevice("iPhone 13 Pro Max")
        .preferredColorScheme(.light)
    }
}
#endif
