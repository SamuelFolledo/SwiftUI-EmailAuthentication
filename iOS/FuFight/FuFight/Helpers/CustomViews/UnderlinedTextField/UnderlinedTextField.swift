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
        case .email, .password, .phoneNumber, .phoneCode, .unknown:
            return .never
        case  .emailOrUsername, .username:
            return .words
        }
    }
}

struct UnderlinedTextField: View {
    var type: FieldType
    @Binding var text: String
    @Binding var hasError: Bool

    var isSecure: Bool = false

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
    }
}
