//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import SwiftUI
import FirebaseAuth

@Observable
class HomeViewModel: ViewModel {
    var account: Account
    var authChangesListener: AuthStateDidChangeListenerHandle?

    ///Set this to nil in order to remove this global loading indicator, empty string will show it but have empty message
    var globalLoadingMessage: String? = nil

    //MARK: - Initializer
    init(account: Account) {
        self.account = account
    }

    //MARK: - ViewModel Overrides

    func onAppear() {
        observeAuthChanges()
    }

    func onDisappear() {
        if let authChangesListener {
            auth.removeStateDidChangeListener(authChangesListener)
        }
    }

    //MARK: - Public Methods
    func logOut() {
        Task {
            do {
                globalLoadingMessage = Str.loggingOut
                try await AccountNetworkManager.logOut()
                transitionToAuthenticationView()
                globalLoadingMessage = Str.updatingUser
                try await AccountNetworkManager.setData(account: account)
                globalLoadingMessage = Str.savingUser
                try await AccountManager.saveCurrent(account)
                globalLoadingMessage = nil
            } catch {
                LOGE("Error logging out \(account.displayName): \(error.localizedDescription)")
                handleError()
            }
        }
    }

    func editPhoto() {
        TODO("Implement edit photo")
    }

    ///Delete in Auth, Firestore, Storage, and then locally
    func deleteAccount() {
        Task {
            let currentUserId = account.id ?? Account.current?.userId ?? account.userId
            do {
                globalLoadingMessage = Str.deletingStoredPhoto
                try await AccountNetworkManager.deleteStoredPhoto(currentUserId)
                globalLoadingMessage = Str.deletingData
                try await AccountNetworkManager.deleteData(currentUserId)
                globalLoadingMessage = Str.deletingUser
                try await AccountNetworkManager.deleteAuthData(userId: currentUserId)
                globalLoadingMessage = Str.loggingOut
                try await AccountNetworkManager.logOut()
                AccountManager.deleteCurrent()
                globalLoadingMessage = nil
                account.reset()
                account.status = .logout
            } catch {
                LOGE("Error deleting account \(error.localizedDescription)")
                handleError()
            }
        }
    }
}

//MARK: - Private Methods
private extension HomeViewModel {
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

    func transitionToAuthenticationView() {
        account.status = .logout
        AccountManager.saveCurrent(account)
    }

    func handleError() {
        ///Clear loading message in order to allow UI interactions again
        globalLoadingMessage = nil
    }
}
