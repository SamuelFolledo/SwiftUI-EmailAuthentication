//
//  BaseAccountViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 3/2/24.
//

import Foundation
import FirebaseAuth

@Observable
class BaseAccountViewModel: BaseViewModel {
    var account: Account
    var authChangesListener: AuthStateDidChangeListenerHandle?
    
    init(account: Account) {
        self.account = account
    }

    override func onAppear() {
        super.onAppear()
        observeAuthChanges()
    }

    override func onDisappear() {
        super.onDisappear()
        if let authChangesListener {
            auth.removeStateDidChangeListener(authChangesListener)
        }
    }
}

private extension BaseAccountViewModel {
    func observeAuthChanges() {
        authChangesListener = auth.addStateDidChangeListener { (authDataResult, user) in
            if let user {
                let updatedAccount = Account(user)
                LOGD("Auth ACCOUNT changes handler for \(user.displayName ?? "")")
                self.account.update(with: updatedAccount)
                AccountManager.saveCurrent(self.account)
            }
        }
    }
}
