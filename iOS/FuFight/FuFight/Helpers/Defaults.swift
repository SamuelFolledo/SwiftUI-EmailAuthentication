//
//  Defaults.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import Foundation

struct Defaults {
    private init() {}
    static let defaults = UserDefaults.standard

    static var showPassword: Bool {
        get {
            defaults.bool(forKey: kSHOWPASSWORD)
        } set {
            defaults.setValue(newValue, forKey: kSHOWPASSWORD)
        }
    }
}
