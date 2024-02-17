//
//  HomeViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/16/24.
//

import SwiftUI

@Observable
class HomeViewModel {
    var user: User

    //MARK: - Initializer
    init(user: User) {
        self.user = user
    }

    //MARK: - Public Methods
    func logout() {
        print("Logging out \(user.fullName)")
        user.accountStatus = .logout
    }
}
