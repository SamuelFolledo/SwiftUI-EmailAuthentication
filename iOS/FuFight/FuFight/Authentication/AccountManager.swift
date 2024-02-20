//
//  AccountManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/19/24.
//

import SwiftUI

///Class in charge of Account stored locally
class AccountManager {
    private init() {}
    private static let defaults = UserDefaults.standard

    static func saveCurrent(_ account: Account) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(account) {
            defaults.set(encoded, forKey: kCURRENTACCOUNT)
        }
    }

    static func getCurrent() -> Account? {
        if let accountData = defaults.object(forKey: kCURRENTACCOUNT) as? Data,
           let account = try? JSONDecoder().decode(Account.self, from: accountData) {
            return account
        }
        return nil
    }

    static func deleteCurrent() {
        defaults.removeObject(forKey: kCURRENTACCOUNT)
    }
}
