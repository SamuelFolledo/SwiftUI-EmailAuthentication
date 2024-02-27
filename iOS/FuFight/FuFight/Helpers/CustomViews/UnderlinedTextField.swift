//
//  UnderlinedTextField.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

enum FieldType {
    case email
    case emailOrUsername
    case password
    case visiblePassword
    case confirmPassword
    case visibleConfirmPassword
    case username
    case phoneNumber
    case phoneCode
    case unspecified

    var placeHolder: String {
        switch self {
        case .email:
            Str.enterEmail
        case .emailOrUsername:
            Str.enterEmailOrUsername
        case .password, .visiblePassword:
            Str.enterPassword
        case .confirmPassword, .visibleConfirmPassword:
            Str.enterPasswordAgain
        case .username:
            Str.enterUsername
        case .phoneNumber:
            Str.enterPhoneNumber
        case .phoneCode:
            Str.enterPhoneSixDigitCode
        case .unspecified:
            ""
        }
    }

    var topFieldKeyboardType: UIKeyboardType {
        switch self {
        case .email, .emailOrUsername:
            .emailAddress
        case .password, .visiblePassword, .confirmPassword, .visibleConfirmPassword, .username, .unspecified:
            .default
        case .phoneNumber:
            .phonePad
        case .phoneCode:
            .numberPad
        }
    }

    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email, .emailOrUsername, .password, .visiblePassword, .confirmPassword, .visibleConfirmPassword, .phoneNumber, .phoneCode, .unspecified:
            .never
        case .username:
            .words
        }
    }

    var contentType: UITextContentType {
        switch self {
        case .email:
            .emailAddress
        case .emailOrUsername:
            .username
        case .password, .visiblePassword, .confirmPassword, .visibleConfirmPassword:
            .password
        case .username:
            .username
        case .phoneNumber:
            .telephoneNumber
        case .phoneCode:
            .oneTimeCode
        case .unspecified:
            .givenName
        }
    }

    var submitLabel: SubmitLabel {
        switch self {
        case .email, .emailOrUsername, .phoneNumber:
            .next
        case .password, .visiblePassword, .confirmPassword, .visibleConfirmPassword, .phoneCode, .username:
            .continue
        case .unspecified:
            .return
        }
    }

    var title: String {
        switch self {
        case .email:
            Str.emailTitle
        case .emailOrUsername:
            Str.emailOrUsernameTitle
        case .password, .visiblePassword:
            Str.passwordTitle
        case .confirmPassword, .visibleConfirmPassword:
            Str.confirmPasswordTitle
        case .username:
            Str.usernameTitle
        case .phoneNumber:
            Str.phoneNumberTitle
        case .phoneCode:
            Str.phoneCodeTitle
        case .unspecified:
            ""
        }
    }
}

struct UnderlinedTextField: View {
    @Binding var type: FieldType
    @Binding var text: String
    @Binding var hasError: Bool
    ///isActive keeps track if this textfield is active and should ALWAYS be in sync with isFocused
    @Binding var isActive: Bool
    @Binding var isDisabled: Bool
    var showTitle: Bool
    var trailingButtonAction: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(type: Binding<FieldType>, text: Binding<String>, hasError: Binding<Bool>, isActive: Binding<Bool>, isDisabled: Binding<Bool> = .constant(false), showTitle: Bool = true, _ trailingButtonAction: (() -> Void)? = nil) {
        self._type = type
        self._text = text
        self._hasError = hasError
        self._isActive = isActive
        self._isDisabled = isDisabled
        self.showTitle = showTitle
        self.trailingButtonAction = trailingButtonAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showTitle {
                Text(type.title)
                    .font(boldedTextFont)
            }

            HStack {
                Group {
                    if type == .password {
                        SecureField(type.placeHolder, text: $text)
                            .foregroundStyle(isDisabled ? .secondary : .primary)
                    } else {
                        TextField(type.placeHolder, text: $text)
                            .foregroundStyle(isDisabled ? .secondary : .primary)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(type.topFieldKeyboardType)
                .textInputAutocapitalization(type.autocapitalization)
                .focused($isFocused)
                .textContentType(type.contentType)
                .submitLabel(type.submitLabel)

                trailingButton
            }
        }
        .padding(.vertical)
        .background(background)
        .onChange(of: text) {
            hasError = text.isEmpty
        }
        .onChange(of: isActive) {
            isFocused = isActive
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.8 : 1)
    }

    var background: some View {
        VStack {
            Spacer()

            Rectangle()
                .frame(height: 1.5)
                .foregroundStyle(hasError ? Color.red : (isDisabled ? Color.systemGray2 : Color.label))
        }
    }

    var trailingButton: some View {
        Button {
            switch type {
            case .password:
                type = .visiblePassword
            case .visiblePassword:
                type = .password
            case .confirmPassword:
                type = .visibleConfirmPassword
            case .visibleConfirmPassword:
                type = .confirmPassword
            case .email, .emailOrUsername, .username, .phoneNumber, .phoneCode, .unspecified:
                trailingButtonAction?()
            }
        } label: {
            switch type {
            case .password, .phoneCode, .confirmPassword:
                Image(systemName: "eye").tint(Color.label)
            case .visiblePassword, .visibleConfirmPassword:
                Image(systemName: "eye.slash").tint(Color.label)
            case .email, .emailOrUsername, .username, .phoneNumber, .unspecified:
                Text("")
                    .hidden()
            }
        }
    }
}
