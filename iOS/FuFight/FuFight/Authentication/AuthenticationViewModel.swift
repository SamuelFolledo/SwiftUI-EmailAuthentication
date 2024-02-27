//
//  AuthenticationViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import UIKit
import SwiftUI

@Observable
class AuthenticationViewModel: BaseViewModel {
    private(set) var step: AuthStep
    let account: Account

    var showForgotPassword: Bool = false
    var rememberMe: Bool = Defaults.saveEmailAndPassword {
        didSet {
            Defaults.saveEmailAndPassword = rememberMe
            saveTopFieldTextIfNeeded()
            saveBottomFieldTextIfNeeded()
        }
    }
    var topFieldType: FieldType = .emailOrUsername
    var topFieldText: String = Defaults.saveEmailAndPassword ? Defaults.savedEmail : "" {
        didSet {
            saveTopFieldTextIfNeeded()
            updateTopFieldTypeIfNeeded()
        }
    }
    var topFieldHasError: Bool = false
    var topFieldIsActive: Bool = false
    var bottomFieldType: FieldType = .password(.current)
    var bottomFieldText: String = Defaults.saveEmailAndPassword ? Defaults.savedPassword : "" {
        didSet {
            saveBottomFieldTextIfNeeded()
        }
    }
    var bottomFieldIsSecure = !Defaults.showPassword {
        didSet {
            Defaults.showPassword = !bottomFieldIsSecure
        }
    }
    var bottomFieldHasError: Bool = false
    var bottomFieldIsActive: Bool = false
    var selectedImage: UIImage? = nil

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

    //MARK: - Public Methods
    func topButtonTapped() {
        bottomFieldIsActive = false
        //TODO: Show loading
        switch step {
        case .logIn:
            logIn()
        case .signUp:
            signUp()
        case .phone:
            TODO("Send phone code")
            updateStep(to: .phoneVerification)
        case .phoneVerification:
            TODO("Login/sign up with phone")
            transitionToHomeView()
        case .onboard:
            finishOnboarding()
        }
    }

    func bottomButtonTapped() {
        switch step {
        case .logIn:
            updateStep(to: .signUp)
        case .signUp:
            updateStep(to: .logIn)
        case .phone, .onboard:
            break
        case .phoneVerification:
            TODO("Cancel registration")
            updateStep(to: .logIn)
        }
    }

    func requestPasswordReset() {
        let email = topFieldText
        Task {
            do {
                try await auth.sendPasswordReset(withEmail: email)
                updateError(nil)
            } catch {
                updateError(MainError(type: .passwordReset, message: error.localizedDescription))
            }
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
    func signUp() {
        Task {
            validateTopField()
            //TODO: 1: Uncomment line below to prevent unsafe passwords
            //        bottomFieldHasError = !bottomFieldText.isValidPassword
            guard !topFieldHasError else {
                return updateError(MainError(type: .invalidEmail))
            }
            guard !bottomFieldHasError else {
                return updateError(MainError(type: .invalidPassword))
            }
            do {
                updateLoadingMessage(to: Str.creatingUser)
                guard let authData = try await AccountNetworkManager.createUser(email: topFieldText, password: bottomFieldText) else { return }
                let updatedAccount = Account(authData)
                account.update(with: updatedAccount)
                updateError(nil)
                updateStep(to: .onboard)
                topFieldIsActive = true
            } catch {
                updateError(MainError(type: .signUp, message: error.localizedDescription))
            }
        }
    }

    func finishOnboarding() {
        validateTopField()
        guard !topFieldHasError else {
            return updateError(MainError(type: .invalidUsername))
        }
        let username = topFieldText.trimmed
        Task {
            do {
                ///Ensure non duplicated username
                updateLoadingMessage(to: Str.checkingUsername)
                guard try await AccountNetworkManager.isUnique(username: username) else {
                    return updateError(MainError(type: .notUniqueUsername))
                }
                ///Store user's photo to Storage
                updateLoadingMessage(to: Str.storingPhoto)
                if let selectedImage,
                   let photoUrl = try await AccountNetworkManager.storePhoto(selectedImage, for: account.userId) {
                    updateLoadingMessage(to: Str.updatingUser)
                    try await AccountNetworkManager.updateAuthenticatedUser(username: username, photoUrl: photoUrl)
                    account.username = username
                    account.photoUrl = photoUrl
                    updateLoadingMessage(to: Str.savingUser)
                    try await AccountNetworkManager.setUsername(username, userId: account.userId, email: account.email)
                    try await AccountNetworkManager.setData(account: account)
                    try await AccountManager.saveCurrent(account)
                    updateError(nil)
                    transitionToHomeView()
                } else {
                    updateError(MainError(type: .onboard, message: "Missing photoUrl"))
                }
            } catch {
                updateError(MainError(type: .onboard, message: error.localizedDescription))
            }
        }
    }

    func logIn() {
        validateTopField()
        let isUsernameAuth = topFieldType == .username
        //TODO: 1: Uncomment line below to prevent unsafe passwords
        //        bottomFieldHasError = !bottomFieldText.isValidPassword
        guard !topFieldHasError else {
            let errorType: MainErrorType = isUsernameAuth ? .invalidUsername : .invalidEmail
            return updateError(MainError(type: errorType))
        }
        guard !bottomFieldHasError else {
            return updateError(MainError(type: .invalidPassword))
        }
        Task {
            do {
                var email = topFieldText
                updateLoadingMessage(to: Str.fetchingEmail)
                if isUsernameAuth,
                   let fetchedEmail = try await AccountNetworkManager.fetchEmailFrom(username: topFieldText) {
                    email = fetchedEmail
                }
                updateLoadingMessage(to: Str.loggingIn)
                ///Authenticate in Auth, then create an account from the fetched data from the database using the authenticated user's userId
                guard let authData = try await AccountNetworkManager.logIn(email: email, password: bottomFieldText) else { return }
                updateLoadingMessage(to: Str.fetchingUserData)
                guard let fetchedAccount = try await AccountNetworkManager.fetchData(userId: authData.user.uid) else { return }
                account.update(with: fetchedAccount)
                updateLoadingMessage(to: Str.savingUser)
                try await AccountManager.saveCurrent(account)
                updateError(nil)
                ///Transition to home view
                transitionToHomeView()
            } catch {
                updateError(MainError(type: .logIn, message: error.localizedDescription))
            }
        }
    }

    func transitionToHomeView() {
        account.status = .online
        AccountManager.saveCurrent(account)
    }

    func resetFields() {
        topFieldIsActive = false
        bottomFieldIsActive = false
        topFieldText = ""
        bottomFieldText = ""
        topFieldHasError = false
        bottomFieldHasError = false
    }

    ///Set topFieldHasError to true if text are not online. This will also trim leading and trailing whitespaces
    func validateTopField() {
        topFieldText = topFieldText.trimmed
        switch step {
        case .logIn:
            switch topFieldType {
            case .password, .phoneNumber, .phoneCode, .unspecified:
                break
            case .email:
                topFieldHasError = !topFieldText.isValidEmail
            case .emailOrUsername:
                topFieldHasError = !(topFieldText.isValidEmail || topFieldText.isValidUsername)
            case .username:
                topFieldHasError = !topFieldText.isValidUsername
            }
        case .signUp:
            topFieldHasError = !topFieldText.isValidEmail
        case .phone, .phoneVerification:
            break
        case .onboard:
            topFieldHasError = !topFieldText.isValidUsername
        }
    }

    ///change topFieldType from email to username if it has "@" and vice versa
    func updateTopFieldTypeIfNeeded() {
        switch step {
        case .onboard:
            topFieldType = .username
        case .signUp:
            topFieldType = .email
        case .logIn:
            if topFieldText.isEmpty {
                topFieldType = .emailOrUsername
                return
            }
            topFieldType = topFieldText.contains("@") ? .email : .username
        case .phone, .phoneVerification:
            break
        }
    }

    func saveTopFieldTextIfNeeded() {
        if rememberMe && !topFieldText.isEmpty {
            Defaults.savedEmail = topFieldText
        } else if !rememberMe {
            Defaults.savedEmail = ""
        }
    }

    func saveBottomFieldTextIfNeeded() {
        let isPassword = bottomFieldType == .password(.current)
        if rememberMe && isPassword && !bottomFieldText.isEmpty {
            Defaults.savedPassword = bottomFieldText
        } else if !rememberMe && isPassword {
            Defaults.savedPassword = ""
        }
    }
}
