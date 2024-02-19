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
        print("Logging out \(user.username)")
        user.accountStatus = .logout
    }
}

//MARK: - Private Methods
private extension HomeViewModel {
    func observeAuthChanges() {
        authChangesListener = auth.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                print("HomeVM: Has changes to current user in Auth")
            } else {
                print("HomeVM: Listened to NO user")
            }
        })
    }
}
