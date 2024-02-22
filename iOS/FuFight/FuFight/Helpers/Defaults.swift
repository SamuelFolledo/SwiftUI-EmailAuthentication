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

    static var saveEmailAndPassword: Bool {
        get {
            defaults.bool(forKey: kSAVEEMAILANDPASSWORD)
        } set {
            defaults.setValue(newValue, forKey: kSAVEEMAILANDPASSWORD)
        }
    }

    static var savedEmail: String {
        get {
            defaults.string(forKey: kSAVEDEMAIL) ?? ""
        } set {
            defaults.setValue(newValue, forKey: kSAVEDEMAIL)
        }
    }

    static var savedPassword: String {
        get {
            defaults.string(forKey: kSAVEDPASSWORD) ?? ""
        } set {
            defaults.setValue(newValue, forKey: kSAVEDPASSWORD)
        }
    }
}
