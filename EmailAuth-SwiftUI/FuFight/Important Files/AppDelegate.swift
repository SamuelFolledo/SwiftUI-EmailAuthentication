//
//  AppDelegate.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI
import FirebaseCore

/*
 [] TODO: 1: Prepare for production
    - Validate logIn page's fields
    - Update Firebase's GoogleServiceInfo.plist
    - Update Firebase Storage's rules
 */

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
