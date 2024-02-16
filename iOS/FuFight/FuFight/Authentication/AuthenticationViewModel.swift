//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import Foundation

enum AuthStep {
    case login, signup, phone, phoneVerification

    var title: String {
        switch self {
        case .login:
            return "Log In"
        case .signup:
            return "Sign Up"
        case .phone:
            return "Phone"
        case .phoneVerification:
            return "Phone Code"
        }
    }
}

class AuthenticationViewModel {
    @Published var step: AuthStep

    //MARK: Constants
//    public let emailTitle

    //MARK: - Initializer

    init(step: AuthStep) {
        self.step = step
    }
}
