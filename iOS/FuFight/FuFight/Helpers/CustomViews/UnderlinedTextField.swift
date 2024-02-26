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
    case username
    case phoneNumber
    case phoneCode
    case unspecified

    var placeHolder: String {
        switch self {
        case .email:
            return Str.emailTitle
        case .emailOrUsername:
            return Str.emailOrUsernameTitle
        case .password, .visiblePassword:
            return Str.passwordTitle
        case .username:
            return Str.usernameTitle
        case .phoneNumber:
            return Str.phoneNumberTitle
        case .phoneCode:
            return Str.phoneSixDigitCodeTitle
        case .unspecified:
            return ""
        }
    }

    var topFieldKeyboardType: UIKeyboardType {
        switch self {
        case .email, .emailOrUsername:
            return .emailAddress
        case .password, .visiblePassword, .username, .unspecified:
            return .default
        case .phoneNumber:
            return .phonePad
        case .phoneCode:
            return .numberPad
        }
    }

    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email, .emailOrUsername, .password, .visiblePassword, .phoneNumber, .phoneCode, .unspecified:
            return .never
        case .username:
            return .words
        }
    }

    var contentType: UITextContentType {
        switch self {
        case .email:
            return .emailAddress
        case .emailOrUsername:
            return .username
        case .password, .visiblePassword:
            return .password
        case .username:
            return .username
        case .phoneNumber:
            return .telephoneNumber
        case .phoneCode:
            return .oneTimeCode
        case .unspecified:
            return .givenName
        }
    }

    var submitLabel: SubmitLabel {
        switch self {
        case .email, .emailOrUsername, .phoneNumber:
            return .next
        case .password, .visiblePassword, .phoneCode, .username:
            return .continue
        case .unspecified:
            return .return
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
    @FocusState private var isFocused: Bool
    var trailingButtonAction: (() -> Void)?

    init(type: Binding<FieldType>, text: Binding<String>, hasError: Binding<Bool>, isActive: Binding<Bool>, isDisabled: Binding<Bool> = .constant(false), _ trailingButtonAction: (() -> Void)? = nil) {
        self._type = type
        self._text = text
        self._hasError = hasError
        self._isActive = isActive
        self._isDisabled = isDisabled
        self.trailingButtonAction = trailingButtonAction
    }

    var body: some View {
        VStack(spacing: 0) {
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

                Button {
                    switch type {
                    case .password:
                        type = .visiblePassword
                    case .visiblePassword:
                        type = .password
                    case .email, .emailOrUsername, .username, .phoneNumber, .phoneCode, .unspecified:
                        trailingButtonAction?()
                    }
                } label: {
                    switch type {
                    case .password, .phoneCode:
                        Image(systemName: "eye").tint(Color.label)
                    case .visiblePassword:
                        Image(systemName: "eye.slash").tint(Color.label)
                    case .email, .emailOrUsername, .username, .phoneNumber, .unspecified:
                        Text("")
                            .hidden()
                    }
                }
            }
        }
        .padding()
        .background(
            VStack {
                Spacer()
                
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundStyle(hasError ? Color.red : (isDisabled ? Color.systemGray2 : Color.label))
            }
        )
        .onChange(of: text) {
            hasError = text.isEmpty
        }
        .onChange(of: isActive) {
            isFocused = isActive
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.8 : 1)
    }
}
