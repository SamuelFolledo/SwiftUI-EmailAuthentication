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

    @ObservedObject private var account = Account()

    var body: some Scene {
        WindowGroup {
            if account.accountStatus == .valid {
                let homeViewModel = HomeViewModel(account: account)
                HomeView(vm: homeViewModel)
            } else {
                let authViewModel = AuthenticationViewModel(step: .logIn, account: account)
                LoginView(vm: authViewModel)
            }
        }
    }
}
