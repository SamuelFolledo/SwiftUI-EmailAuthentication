//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import SwiftUI
import FirebaseAuth

@Observable
class HomeViewModel: BaseViewModel {
    var account: Account
    var authChangesListener: AuthStateDidChangeListenerHandle?
    var isAccountVerified = false

    //MARK: - Initializer
    init(account: Account) {
        self.account = account
    }

    //MARK: - ViewModel Overrides

    override func onAppear() {
        super.onAppear()
        observeAuthChanges()
        if !isAccountVerified {
            verifyAccount()
        }
    }

    override func onDisappear() {
        super.onDisappear()
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

    ///Make sure account is valid at least once
    func verifyAccount() {
        Task {
            do {
                if try await AccountNetworkManager.isAccountValid(userId: account.userId) {
                    LOGD("Account verified")
                    isAccountVerified = true
                    return
                }
                LOGE("Account is invalid \(account.displayName) with id \(account.userId)")
                AccountManager.deleteCurrent()
                updateError(nil)
                account.reset()
                account.status = .logOut
                if Defaults.isSavingEmailAndPassword {
                    Defaults.savedEmailOrUsername = ""
                    Defaults.savedPassword = ""
                }
            } catch {
                updateError(MainError(type: .deletingUser, message: error.localizedDescription))
            }
        }
    }
}
