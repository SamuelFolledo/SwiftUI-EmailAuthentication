//
//  UpdatePasswordViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/26/24.
//

import SwiftUI

@Observable
class UpdatePasswordViewModel: BaseViewModel {
    var currentPassword = ""
    var currentPasswordFieldType: FieldType = .password(.current)
    var currentPasswordIsSecure = true
    var currentPasswordHasError = false
    var currentPasswordIsActive = false
    var password = "" {
        didSet {
            validateNewPassword()
        }
    }
    var passwordFieldType: FieldType = .password(.new)
    var passwordIsSecure = true
    var passwordHasError = false
    var passwordIsActive = false
    var confirmPassword = "" {
        didSet {
            validateConfirmNewPassword()
        }
    }
    var confirmPasswordFieldType: FieldType = .password(.confirmNew)
    var confirmPasswordIsSecure = true
    var confirmPasswordHasError = false
    var confirmPasswordIsActive = false
    var isUpdatePasswordButtonEnabled: Bool {
        if currentPassword.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return false
        }
        return !currentPasswordHasError && !passwordHasError && !confirmPasswordHasError
    }

    override func onAppear() {
        super.onAppear()
        currentPasswordIsActive = true
    }

    //MARK: - Public Methods

    func updatePasswordButtonTapped() {
        currentPasswordIsActive = false
        passwordIsActive = false
        confirmPasswordIsActive = false
        validateNewPassword()
        validateConfirmNewPassword()
        updatePassword()
    }
}

private extension UpdatePasswordViewModel {
    func updatePassword() {
        guard !currentPasswordHasError, !passwordHasError, !confirmPasswordHasError else { return }
        Task {
            do {
                ///Reauthenticate
                updateLoadingMessage(to: Str.reauthenticatingAccount)
                try await AccountNetworkManager.reauthenticateUser(password: currentPassword)
                ///Update password
                updateLoadingMessage(to: Str.updatingPassword)
                try await AccountNetworkManager.updatePassword(password)
                updateError(nil)
                LOGD("Finished updating password for \(auth.currentUser!.displayName!)")
                dismissView()
            } catch {
                updateError(MainError(type: .deletingUser, message: error.localizedDescription))
            }
        }
    }

    func validateNewPassword() {
        //TODO: 1 Uncomment line below to prevent new unsafe password
//        passwordHasError = password.trimmed.isValidPassword
    }

    func validateConfirmNewPassword() {
        //TODO: 1 Uncomment line below to prevent new unsafe password
        //        passwordHasError = confirmPassword.trimmed.isValidPassword
        confirmPasswordHasError = confirmPassword.trimmed != password.trimmed
    }
}
