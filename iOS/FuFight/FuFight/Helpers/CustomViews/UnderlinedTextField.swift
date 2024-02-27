//
//  UnderlinedTextField.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

enum PasswordType {
    case current
    case new
    case confirmNew

    var title: String {
        switch self {
        case .current:
            Str.passwordTitle
        case .new:
            Str.newTitle
        case .confirmNew:
            Str.confirmNewPasswordTitle
        }
    }

    var placeholder: String {
        switch self {
        case .current:
            Str.enterPassword
        case .new:
            Str.enterNewPassword
        case .confirmNew:
            Str.confirmNewPassword
        }
    }
}

enum FieldType: Equatable {
    case email
    case emailOrUsername
    case password(_ type: PasswordType)
    case username
    case phoneNumber
    case phoneCode
    case unspecified(title: String, placeholder: String)

    var placeholder: String {
        switch self {
        case .email:
            Str.enterEmail
        case .emailOrUsername:
            Str.enterEmailOrUsername
        case .password(let type):
            type.placeholder
        case .username:
            Str.enterUsername
        case .phoneNumber:
            Str.enterPhoneNumber
        case .phoneCode:
            Str.enterPhoneSixDigitCode
        case .unspecified(_, let placeholder):
            placeholder
        }
    }

    var topFieldKeyboardType: UIKeyboardType {
        switch self {
        case .email, .emailOrUsername:
            .emailAddress
        case .password, .username, .unspecified:
            .default
        case .phoneNumber:
            .phonePad
        case .phoneCode:
            .numberPad
        }
    }

    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email, .emailOrUsername, .password, .phoneNumber, .phoneCode, .unspecified:
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
        case .password:
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
        case .password, .phoneCode, .username:
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
        case .password(let type):
            type.title
        case .username:
            Str.usernameTitle
        case .phoneNumber:
            Str.phoneNumberTitle
        case .phoneCode:
            Str.phoneCodeTitle
        case .unspecified(let title, _):
            title
        }
    }
}

struct UnderlinedTextField: View {
    @Binding var type: FieldType
    @Binding var text: String
    @Binding var isSecure: Bool
    @Binding var hasError: Bool
    ///isActive keeps track if this textfield is active and should ALWAYS be in sync with isFocused
    @Binding var isActive: Bool
    @Binding var isDisabled: Bool
    var showTitle: Bool
    var trailingButtonAction: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(type: Binding<FieldType>, text: Binding<String>, isSecure: Binding<Bool> = .constant(false), hasError: Binding<Bool>, isActive: Binding<Bool>, isDisabled: Binding<Bool> = .constant(false), showTitle: Bool = true, _ trailingButtonAction: (() -> Void)? = nil) {
        self._type = type
        self._text = text
        self._isSecure = isSecure
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
                    if isSecure {
                        SecureField(type.placeholder, text: $text)
                            .foregroundStyle(isDisabled ? .secondary : .primary)
                    } else {
                        TextField(type.placeholder, text: $text)
                            .foregroundStyle(isDisabled ? .secondary : .primary)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(type.topFieldKeyboardType)
                .textInputAutocapitalization(type.autocapitalization)
                .focused($isFocused)
                .textContentType(type.contentType)
                .submitLabel(type.submitLabel)

                accessories
            }
        }
        .padding(.vertical)
        .background(background)
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

    var accessories: some View {
        HStack {
            checkmark()

            trailingButton
        }
    }

    var trailingButton: some View {
        Button {
            switch type {
            case .password(_):
                isSecure = !isSecure
            case .email, .emailOrUsername, .username, .phoneNumber, .phoneCode, .unspecified:
                trailingButtonAction?()
            }
        } label: {
            switch type {
            case .phoneCode:
                isSecuredImage()
            case .password(_):
                isSecuredImage()
            case .email, .emailOrUsername, .username, .phoneNumber, .unspecified:
                EmptyView()
            }
        }
    }

    @ViewBuilder func checkmark() -> some View {
        if hasError {
            invalidImage
        } else {
            if text.isEmpty {
                EmptyView()
            } else {
                switch type {
                case .password(let passwordType):
                    switch passwordType {
                    case .current:
                        EmptyView()
                    case .new:
                        //TODO: 1 Uncomment lines below to prevent unsafe password
//                        if text.isValidPassword {
//                            validImage
//                        } else {
//                            invalidImage
//                        }
                        validImage
                    case .confirmNew:
                        validImage
                    }
                case .email, .emailOrUsername, .username, .phoneNumber, .phoneCode, .unspecified:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder func isSecuredImage() -> some View {
        if isSecure {
            securedImage
        } else {
            nonSecuredImage
        }
    }
}

#Preview {
    VStack {
        UnderlinedTextField(type: .constant(.email), text: .constant("samuelfolledo@gmail.com"), hasError: .constant(false), isActive: .constant(false))

        UnderlinedTextField(type: .constant(.password(.confirmNew)), text: .constant("pass123"), isSecure: .constant(true), hasError: .constant(true), isActive: .constant(false))

        UnderlinedTextField(type: .constant(.password(.confirmNew)), text: .constant("Pass123!"), isSecure: .constant(false), hasError: .constant(false), isActive: .constant(false))
    }
    .padding()
}
