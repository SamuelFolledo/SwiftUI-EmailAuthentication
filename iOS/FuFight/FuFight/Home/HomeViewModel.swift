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
    func logout() {
        print("Logging out \(account.displayName)")
        account.accountStatus = .logout
    }
}

//MARK: - Private Methods
private extension HomeViewModel {
    func observeAuthChanges() {
        auth.addStateDidChangeListener { (authDataResult, user) in
//            if let authDataResult {
//                let updatedAccount = Account(authResult: authDataResult.currentUser)
//                self.account.update(with: updatedAccount)
//                print("HomeVM: Has changes to current user in Auth")
//            } else {
//                print("HomeVM: Listened to NO user")
//            }
        }
    }
}
