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
                await transitionToAuthenticationView()
                try await AccountNetworkManager.setData(account: account)
                try await AccountManager.saveCurrent(account)
            } catch {
                print("Error deleting account \(error.localizedDescription)")
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
                print("Auth ACCOUNT changes handler for \(user.displayName ?? "")")
                updatedAccount.status = self.account.status
                DispatchQueue.main.async {
                    self.account.update(with: updatedAccount)
                }
            }
        }
    }

    func transitionToAuthenticationView() async {
        DispatchQueue.main.async {
            self.account.status = .logout
        }
    }
}
