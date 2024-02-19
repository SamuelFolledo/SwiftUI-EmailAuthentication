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
    case username
    case phoneNumber
    case phoneCode
    case unknown

    var placeHolder: String {
        switch self {
        case .email:
            return Str.emailTitle
        case .emailOrUsername:
            return Str.emailOrUsernameTitle
        case .password:
            return Str.passwordTitle
        case .username:
            return Str.usernameTitle
        case .phoneNumber:
            return Str.phoneNumberTitle
        case .phoneCode:
            return Str.phoneSixDigitCodeTitle
        case .unknown:
            return ""
        }
    }

    var topFieldKeyboardType: UIKeyboardType {
        switch self {
        case .email, .emailOrUsername:
            return .emailAddress
        case .password, .username, .unknown:
            return .default
        case .phoneNumber:
            return .phonePad
        case .phoneCode:
            return .numberPad
        }
    }

    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email, .emailOrUsername, .password, .phoneNumber, .phoneCode, .unknown:
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
        case .password:
            return .password
        case .username:
            return .username
        case .phoneNumber:
            return .telephoneNumber
        case .phoneCode:
            return .oneTimeCode
        case .unknown:
            return .givenName
        }
    }

    var submitLabel: SubmitLabel {
        switch self {
        case .email, .emailOrUsername, .username, .phoneNumber:
            return .next
        case .password, .phoneCode:
            return .done
        case .unknown:
            return .return
        }
    }
}

struct UnderlinedTextField: View {
    var type: FieldType
    @Binding var text: String
    @Binding var hasError: Bool
    ///isActive keeps track if this textfield is active and should ALWAYS be in sync with isFocused
    @Binding var isActive: Bool
    @FocusState private var isFocused: Bool
    var isSecure: Bool

    init(type: FieldType, text: Binding<String>, hasError: Binding<Bool>, isActive: Binding<Bool>, isSecure: Bool = false) {
        self.type = type
        self._text = text
        self._hasError = hasError
        self._isActive = isActive
        self.isSecure = isSecure
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if isSecure {
                    SecureField(type.placeHolder, text: $text)
                } else {
                    TextField(type.placeHolder, text: $text)
                }
            }
            .padding()
            .textFieldStyle(PlainTextFieldStyle())
            .keyboardType(type.topFieldKeyboardType)
            .textInputAutocapitalization(type.autocapitalization)
            .focused($isFocused)
            .textContentType(type.contentType)
            .submitLabel(type.submitLabel)
        }
        .background(
            VStack {
                Spacer()
                
                Rectangle()
                    .frame(height: 1.5)
                    .padding(.horizontal)
                    .foregroundStyle(hasError ? Color.red : Color.label)
            }
        )
        .onChange(of: text) {
            hasError = text.isEmpty
        }
        .onChange(of: isActive) {
            isFocused = isActive
        }
    }
}
