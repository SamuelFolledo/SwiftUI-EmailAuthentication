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
    var user: User
    var authChangesListener: AuthStateDidChangeListenerHandle?

    //MARK: - Initializer
    init(user: User) {
        self.user = user
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
        print("Logging out \(user.displayName)")
        user.accountStatus = .logout
    }
}

//MARK: - Private Methods
private extension HomeViewModel {
    func observeAuthChanges() {
        auth.addStateDidChangeListener { (authDataResult, user) in
//            if let authDataResult {
//                let updatedUser = User(authResult: authDataResult.currentUser)
//                self.user.update(with: updatedUser)
//                print("HomeVM: Has changes to current user in Auth")
//            } else {
//                print("HomeVM: Listened to NO user")
//            }
        }
    }
}
