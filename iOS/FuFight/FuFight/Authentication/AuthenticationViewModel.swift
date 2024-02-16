//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import UIKit

enum AuthStep {
    case login, signup, phone, phoneVerification

    var title: String {
        switch self {
        case .login:
            return Str.loginTitle
        case .signup:
            return Str.signupTitle
        case .phone:
            return Str.phoneTitle
        case .phoneVerification:
            return Str.phoneCodeTitle
        }
    }

    var topFieldPlaceholder: String {
        switch self {
        case .login:
            return Str.emailOrUsernameTitle
        case .signup:
            return Str.emailTitle
        case .phone:
            return Str.phoneTitle
        case .phoneVerification:
            return ""
            
        }
    }

    var topFieldKeyboardType: UIKeyboardType {
        switch self {
        case .login, .signup:
            return .emailAddress
        case .phone, .phoneVerification:
            return .phonePad
        }
    }

    var bottomFieldPlaceholder: String {
        switch self {
        case .login, .signup:
            return Str.passwordTitle
        case .phone:
            return ""
        case .phoneVerification:
            return Str.phoneDigitCodeTitle
        }
    }

    var bottomFieldKeyboardType: UIKeyboardType {
        switch self {
        case .login, .signup:
            return .default
        case . phone, .phoneVerification:
            return .numberPad
        }
    }

    var topButtonTitle: String {
        switch self {
        case .login:
            return Str.loginTitle
        case .signup:
            return Str.createAccountTitle
        case .phone:
            return Str.sendCode
        case .phoneVerification:
            return Str.verifyCode
        }
    }

    var bottomButtonTitle: String {
        switch self {
        case .login:
            return Str.dontHaveAnAccount
        case .signup:
            return Str.alreadyHaveAnAccount
        case .phone:
            return ""
        case .phoneVerification:
            return Str.cancelTitle
        }
    }
}

@Observable
class AuthenticationViewModel {
    private(set) var step: AuthStep
    private(set) var user: User?
    var username: String = ""
    var topFieldText: String = ""
    var bottomFieldText: String = ""

    //MARK: - Initializer

    init(step: AuthStep) {
        self.step = step
    }

    //MARK: - Public Methods
    func topButtonTapped() {
        switch step {
        case .login:
            print("TODO: Log in, then go to game view")
            validateUser()
        case .signup:
            print("TODO: Sign up, then go to game view")
            validateUser()
        case .phone:
            print("TODO: Send phone code")
            step = .phoneVerification
        case .phoneVerification:
            print("TODO: Login/sign up with phone")
            validateUser()
        }
    }

    func bottomButtonTapped() {
        switch step {
        case .login:
            step = .signup
        case .signup:
            step = .login
        case .phone:
            print("TODO: button should be hidden")
            break
        case .phoneVerification:
            print("TODO: Cancel registration")
            step = .login
        }
    }
}

private extension AuthenticationViewModel {
    func validateUser() {
        if let user {
            user.accountStatus = .valid
        } else {
            let isPhone = step == .phone || step == .phoneVerification
            if isPhone {
                user = User.init(userId: "123", username: username, firstName: "FName", lastName: "LName", phoneNumber: topFieldText, createdAt: Date(), updatedAt: Date())
            } else {
                user = User.init(userId: "123", username: username, firstName: "FName", lastName: "LName", email: topFieldText, createdAt: Date(), updatedAt: Date())
            }
            validateUser()
        }
    }
}
