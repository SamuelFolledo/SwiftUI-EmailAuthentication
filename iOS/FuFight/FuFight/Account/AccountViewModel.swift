//
//  AccountViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

@Observable
class AccountViewModel: ViewModel {
    var account: Account

    ///Set this to nil in order to remove this global loading indicator, empty string will show it but have empty message
    var loadingMessage: String? = nil
    var hasError: Bool = false
    var error: MainError?
    var selectedImage: UIImage = defaultProfilePhoto

    var usernameFieldText: String = Account.current?.username ?? ""
    var usernameFieldHasError: Bool = false
    var usernameFieldIsActive: Bool = false
    var emailFieldText: String = Account.current?.email ?? ""
    var emailFieldHasError: Bool = false
    var emailFieldIsActive: Bool = false

    //MARK: - Initializer
    init(account: Account) {
        self.account = account
    }

    //MARK: - ViewModel Overrides

    func onAppear() {
        observeAuthChanges()
    }

    func onDisappear() { }

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
                updateLoadingMessage(to: Str.loggingOut)
                try await AccountNetworkManager.logOut()
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

    func saveButtonTapped() {
        TODO("Save")
    }

    func changePasswordButtonTapped() {
        TODO("Update password")
    }
}

//MARK: - Private Methods
private extension AccountViewModel {
    func transitionToAuthenticationView() {
        account.status = .logOut
        AccountManager.saveCurrent(account)
    }
}

//MARK: Reusable methods for all ViewModel
private extension AccountViewModel {
    func observeAuthChanges() {
        auth.addStateDidChangeListener { (authDataResult, user) in
            if let user {
                let updatedAccount = Account(user)
                LOGD("Auth ACCOUNT changes handler for \(user.displayName ?? "")")
                updatedAccount.status = self.account.status
                self.account.update(with: updatedAccount)
                AccountManager.saveCurrent(self.account)
            }
        }
    }
    
    func updateError(_ error: MainError?) {
        updateLoadingMessage(to: nil)
        DispatchQueue.main.async {
            if let error {
                LOGE(error.fullMessage)
                self.error = error
                self.hasError = true
            } else {
                ///clear error messages
                self.hasError = false
                self.error = nil
            }
        }
    }

    func updateLoadingMessage(to message: String?) {
        DispatchQueue.main.async {
            self.loadingMessage = message
        }
    }
}
