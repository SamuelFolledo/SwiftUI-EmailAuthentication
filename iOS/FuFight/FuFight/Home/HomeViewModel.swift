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
    var loadingMessage: String? = nil
    var hasError: Bool = false
    var error: MainError?

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
}

//MARK: - Private Methods
private extension HomeViewModel { }

//MARK: Reusable methods for all ViewModel
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
