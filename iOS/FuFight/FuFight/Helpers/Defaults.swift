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

    static var isSavingEmailAndPassword: Bool {
        get {
            defaults.bool(forKey: kISSAVINGEMAILANDPASSWORD)
        } set {
            defaults.setValue(newValue, forKey: kISSAVINGEMAILANDPASSWORD)
        }
    }

    static var savedEmailOrUsername: String {
        get {
            defaults.string(forKey: kSAVEDEMAILORUSERNAME) ?? ""
        } set {
            if newValue.isEmpty {
                defaults.removeObject(forKey: kSAVEDEMAILORUSERNAME)
            } else {
                defaults.setValue(newValue, forKey: kSAVEDEMAILORUSERNAME)
            }
        }
    }

    static var savedPassword: String {
        get {
            defaults.string(forKey: kSAVEDPASSWORD) ?? ""
        } set {
            if newValue.isEmpty {
                defaults.removeObject(forKey: kSAVEDPASSWORD)
            } else {
                defaults.setValue(newValue, forKey: kSAVEDPASSWORD)
            }
        }
    }
}
