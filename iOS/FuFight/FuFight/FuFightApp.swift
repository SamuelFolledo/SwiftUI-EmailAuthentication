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

    @ObservedObject private var user = User()

    var body: some Scene {
        WindowGroup {
            if user.accountStatus == .valid {
                let homeViewModel = HomeViewModel(user: user)
                HomeView(vm: homeViewModel)
            } else {
                let authViewModel = AuthenticationViewModel(step: .logIn, user: user)
                LoginView(vm: authViewModel)
            }
        }
    }
}
