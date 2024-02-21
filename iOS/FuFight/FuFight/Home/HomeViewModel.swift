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
                try await AccountNetworkManager.logOut()
                transitionToAuthenticationView()
                try await AccountNetworkManager.setData(account: account)
                try await AccountManager.saveCurrent(account)
            } catch {
                LOGE("Error logging out \(account.displayName): \(error.localizedDescription)")
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
                try await AccountNetworkManager.deleteStoredPhoto(currentUserId)
                try await AccountNetworkManager.deleteData(currentUserId)
                try await AccountNetworkManager.deleteAuthData(userId: currentUserId)
                try await AccountNetworkManager.logOut()
                AccountManager.deleteCurrent()
                account.reset()
                account.status = .logout
            } catch {
                LOGE("Error deleting account \(error.localizedDescription)")
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
}
