//
//  AuthStep.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/20/24.
//

import Foundation

enum AuthStep {
    case logIn, signUp, phone, phoneVerification
    ///Step after signing up to add username and profile picture
    case onboard

    var title: String {
        switch self {
        case .logIn:
            return Str.logInTitle
        case .signUp:
            return Str.signUpTitle
        case .phone:
            return Str.phoneTitle
        case .phoneVerification:
            return Str.phoneCodeTitle
        case .onboard:
            return Str.finishSignUpTitle
        }
    }

    var topFieldType: FieldType {
        switch self {
        case .logIn:
            return .emailOrUsername
        case .signUp:
            return .email
        case .phone:
            return .phoneNumber
        case .phoneVerification:
            return .phoneCode
        case .onboard:
            return .username
        }
    }

    var topButtonTitle: String {
        switch self {
        case .logIn:
            return Str.logInTitle
        case .signUp:
            return Str.createAccountTitle
        case .phone:
            return Str.sendCode
        case .phoneVerification:
            return Str.verifyCode
        case .onboard:
            return Str.finishTitle
        }
    }

    var bottomFieldType: FieldType {
        switch self {
        case .logIn, .signUp:
            return Defaults.showPassword ? .visiblePassword : .password
        case .phone:
            return .phoneCode
        case .phoneVerification:
            return .phoneCode
        case .onboard:
            //Should not appear
            return .username
        }
    }

    var bottomButtonTitle: String {
        switch self {
        case .logIn:
            return Str.dontHaveAnAccount
        case .signUp:
            return Str.alreadyHaveAnAccount
        case .phone, .onboard:
            return ""
        case .phoneVerification:
            return Str.cancelTitle
        }
    }
}
