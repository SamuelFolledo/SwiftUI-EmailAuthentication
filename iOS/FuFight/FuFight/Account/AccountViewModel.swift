//
//  AccountViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

@Observable
class AccountViewModel: BaseViewModel {
    var account: Account

    var isViewingMode: Bool = true
    var selectedImage: UIImage = defaultProfilePhoto
    var usernameFieldText: String = Account.current?.username ?? ""
    var usernameFieldHasError: Bool = false
    var usernameFieldIsActive: Bool = false
    var emailFieldText: String = Account.current?.email ?? ""
    var emailFieldHasError: Bool = false
    var emailFieldIsActive: Bool = false
    var isDeleteAccountAlertPresented: Bool = false

    //MARK: - Initializer
    init(account: Account) {
        self.account = account
    }

    //MARK: - Public Methods
    func logOut() {
        Task {
            do {
                updateLoadingMessage(to: Str.loggingOut)
                try await AccountNetworkManager.logOut()
                transitionToAuthenticationView()
                updateLoadingMessage(to: Str.updatingUser)
                try await AccountNetworkManager.setData(account: account)
                updateLoadingMessage(to: Str.savingUser)
                try await AccountManager.saveCurrent(account)
                updateError(nil)
            } catch {
                updateError(MainError(type: .logOut, message: error.localizedDescription))
            }
        }
    }

    ///Delete in Auth, Firestore, Storage, and then locally
    func deleteAccount() {
        Task {
            let currentUserId = account.id ?? Account.current?.userId ?? account.userId
            do {
                updateLoadingMessage(to: Str.deletingStoredPhoto)
                try await AccountNetworkManager.deleteStoredPhoto(currentUserId)
                updateLoadingMessage(to: Str.deletingData)
                try await AccountNetworkManager.deleteData(currentUserId)
                updateLoadingMessage(to: Str.deletingUsername)
                try await AccountNetworkManager.deleteUsername(account.username!)
                updateLoadingMessage(to: Str.deletingUser)
                try await AccountNetworkManager.deleteAuthData(userId: currentUserId)
                AccountManager.deleteCurrent()
                updateError(nil)
                account.reset()
                account.status = .logOut
            } catch {
                updateError(MainError(type: .deletingUser, message: error.localizedDescription))
            }
        }
    }

    func editPhoto() {
        TODO("Implement edit photo")
    }

    func editSaveButtonTapped() {
        if !isViewingMode {
            //TODO: Validate fields
            let username = usernameFieldText.trimmed
            let email = emailFieldText.trimmed
            guard !username.isEmpty, !email.isEmpty else { return }
            Task {
                ///Update authenticated user's displayName
                let didChangeUsername = username.lowercased() != account.displayName.trimmed.lowercased()
                if didChangeUsername {
                    updateLoadingMessage(to: Str.updatingUsername)
                    try await AccountNetworkManager.updateAuthenticatedUser(username: username)
                    ///Delete old username
                    updateLoadingMessage(to: Str.deletingUsername)
                    try await AccountNetworkManager.deleteUsername(account.username!)
                    account.username = username
                }
                var email: String? = nil
                let didChangeEmail = emailFieldText.trimmed.lowercased() != account.email!.trimmed.lowercased()
                if didChangeEmail {
                    email = emailFieldText.trimmed
                    account.email = email
                    //TODO: Update email
                }
                ///Save username
                updateLoadingMessage(to: Str.savingUser)
                try await AccountNetworkManager.setUsername(username, userId: account.userId, email: account.email)
                try await AccountNetworkManager.setData(account: account)
                try await AccountManager.saveCurrent(account)
                updateError(nil)
                LOGD("Successfully editted user with \(auth.currentUser!.displayName!) and \(auth.currentUser!.email!)")
            }
        }
        isViewingMode = !isViewingMode
    }

    func changePasswordButtonTapped() {
        Task {
            let currentUserId = account.id ?? Account.current?.userId ?? account.userId
            do {
                TODO("Update password")
            } catch {
                updateError(MainError(type: .deletingUser, message: error.localizedDescription))
            }
        }
    }
}

//MARK: - Private Methods
private extension AccountViewModel {
    func transitionToAuthenticationView() {
        account.status = .logOut
        AccountManager.saveCurrent(account)
    }
}
