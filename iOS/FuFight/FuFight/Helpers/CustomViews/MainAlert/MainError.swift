//
//  MainError.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import Foundation

enum MainErrorType {
    case logOut
    case logIn
    case signUp
    case onboard
    case uploadingImage
    case creatingUser
    case gettingUser
    case updatingUser
    case deletingUser
    case passwordReset
    case invalidEmail
    case emptyEmail
    case invalidPassword
    case emptyPassword
    case invalidUsername
    case emptyUsername
    case notUniqueUsername
    case noEmailFromUsername
    case reauthenticatingUser

    var title: String {
        switch self {
        case .logOut:
            "Error logging out"
        case .logIn:
            "Error logging in"
        case .signUp:
            "Error signing up"
        case .onboard:
            "Error onboarding"
        case .uploadingImage:
            "Error uploading image"
        case .creatingUser:
            "Error creating user"
        case .gettingUser:
            "Error getting user"
        case .updatingUser:
            "Error updating user"
        case .deletingUser:
            "Error deleting user"
        case .passwordReset:
            "Error sending reset password link"
        case .invalidEmail:
            "Invalid email"
        case .invalidPassword:
            "Invalid password"
        case .invalidUsername:
            "Invalid username"
        case .notUniqueUsername:
            "Username is already taken"
        case .emptyEmail:
            "Email is empty"
        case .emptyPassword:
            "Password is empty"
        case .emptyUsername:
            "Username is empty"
        case .reauthenticatingUser:
            "Error reauthenticating user"
        case .noEmailFromUsername:
            "Could not fetch email from username provided"
        }
    }
}

struct MainError {
    var type: MainErrorType?
    var title: String
    var message: String?
    var fullMessage: String {
        return message == nil ? "\(title)" : "\(title)\n\(message ?? "")"
    }

    init(title: String, messaging: String) {
        self.title = title
        self.message = messaging
    }

    init(type: MainErrorType, message: String = "") {
        self.type = type
        self.title = type.title
        self.message = message
    }
}
