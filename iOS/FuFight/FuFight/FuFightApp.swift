//
//  FuFightApp.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

@main
struct FuFightApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var user: User?
    let authViewModel = AuthenticationViewModel(step: .login)

    var body: some Scene {
        WindowGroup {
            if let user = authViewModel.user,
                user.accountStatus == .valid {
                HomeView()
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}
