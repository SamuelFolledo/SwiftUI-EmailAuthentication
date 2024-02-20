//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import UIKit
import SwiftUI

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
            return .password
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

@Observable
class AuthenticationViewModel: ViewModel {
    private(set) var step: AuthStep
    let account: Account
    var username: String = ""
    var topFieldText: String = ""
    var topFieldHasError: Bool = false
    var topFieldIsActive: Bool = false
    var bottomFieldText: String = ""
    var bottomFieldHasError: Bool = false
    var bottomFieldIsActive: Bool = false
    var error: Error?
    var selectedImage: UIImage = defaultProfilePhoto

    var topButtonIsEnabled: Bool {
        switch step {
        case .logIn, .signUp:
            return topFieldText.count >= 3 && bottomFieldText.count >= 3
        case .phone, .onboard:
            return topFieldText.count >= 3
        case .phoneVerification:
            return bottomFieldText.count >= 6
        }
    }

    //MARK: - Initializer

    init(step: AuthStep, account: Account) {
        self.step = step
        self.account = account
    }

    //MARK: - ViewModel Overrides
    func onAppear() { }

    func onDisappear() { }

    //MARK: - Public Methods
    func topButtonTapped() {
        bottomFieldIsActive = false
        //TODO: Show loading
        switch step {
        case .logIn:
            print("TODO: Log in, then go to game view")
            validateAccount()
        case .signUp:
            Task {
                await signUp()
                topFieldIsActive = true
            }
        case .phone:
            print("TODO: Send phone code")
            updateStep(to: .phoneVerification)
        case .phoneVerification:
            print("TODO: Login/sign up with phone")
            validateAccount()
        case .onboard:
            Task {
                await finishAccountCreation()
            }
        }
    }

    func bottomButtonTapped() {
        switch step {
        case .logIn:
            updateStep(to: .signUp)
        case .signUp:
            updateStep(to: .logIn)
        case .phone, .onboard:
            print("TODO: button should be hidden")
            break
        case .phoneVerification:
            print("TODO: Cancel registration")
            updateStep(to: .logIn)
        }
    }

    func onTopFieldReturnButtonTapped() {
        switch step {
        case .logIn, .signUp, .phone:
            validateTopField()
            topFieldIsActive = false
            bottomFieldIsActive = true
        case .phoneVerification, .onboard:
            topButtonTapped()
        }
    }

    func onBottomFieldReturnButtonTapped() {
        topButtonTapped()
    }

    func updateStep(to toStep: AuthStep) {
        step = toStep
        switch toStep {
        case .logIn:
            resetFields()
        case .signUp:
            resetFields()
        case .phone:
            resetFields()
        case .phoneVerification:
            break
        case .onboard:
            resetFields()
        }
    }
}

private extension AuthenticationViewModel {
    func signUp() async {
        validateTopField()
        //TODO: 1: Uncomment line below to prevent unsafe passwords
//        bottomFieldHasError = !bottomFieldText.isValidPassword
        if !topFieldHasError && !bottomFieldHasError {
            do {
                guard let authData = try await AccountNetworkManager.createAccount(email: topFieldText, password: bottomFieldText) else { return }
                let updatedAccount = Account(authData)
                self.account.update(with: updatedAccount)
                self.updateStep(to: .onboard)
            } catch {
                print("Error signing up \(error.localizedDescription)")
            }
        } else {
            print("Email has error \(topFieldHasError) or password has error \(bottomFieldHasError)")
        }
    }

    func finishAccountCreation() async {
        validateTopField()
        if !topFieldHasError {
            do {
                if let imageUrl = try await AccountNetworkManager.storeImage(selectedImage, for: account.userId) {
                    try await AccountNetworkManager.updateAuthenticatedAccount(username: topFieldText, photoURL: imageUrl)
                    account.update(username: topFieldText, imageUrl: imageUrl)
                    try await AccountNetworkManager.setData(account: account)
                    validateAccount()
                    print("TODO: Go to home page after successfully updating user's database")
                }
            } catch {
                print("Error Finishing Account creation \(error.localizedDescription)")
            }
        }
    }

    func validateAccount() {
//        let isPhone = step == .phone || step == .phoneVerification
        DispatchQueue.main.async {
            self.account.accountStatus = .valid
        }
    }

    func resetFields() {
        topFieldIsActive = false
        bottomFieldIsActive = false
        topFieldText = ""
        bottomFieldText = ""
        topFieldHasError = false
        bottomFieldHasError = false
    }

    ///Set topFieldHasError to true if text are not valid. This will also trim leading and trailing whitespaces
    func validateTopField() {
        topFieldText = topFieldText.trimmed
        switch step {
        case .logIn:
            topFieldHasError = !topFieldText.isValidEmail || !topFieldText.isValidUsername
        case .signUp:
            topFieldHasError = !topFieldText.isValidEmail
        case .phone, .phoneVerification:
            break
        case .onboard:
            topFieldHasError = !topFieldText.isValidUsername
        }
    }
}
