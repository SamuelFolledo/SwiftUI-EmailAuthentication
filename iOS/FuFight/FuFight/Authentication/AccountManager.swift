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

    static func saveCurrent(_ account: Account) async throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(account)
            LOGD("ACCOUNT: Locally saving \(account.displayName) with status of \(account.status)")
            defaults.set(data, forKey: kCURRENTACCOUNT)
        } catch {
            throw error
        }
    }

    static func getCurrent() -> Account? {
        guard let data = defaults.data(forKey: kCURRENTACCOUNT) else { return nil }
        do {
            let account = try JSONDecoder().decode(Account.self, from: data)
            LOGD("ACCOUNT: Locally getting \(account.displayName) with status of \(account.status)")
            return account
        } catch {
            LOGE("Error decoding current account \(error.localizedDescription)")
            return nil
        }
    }

    static func deleteCurrent() {
        defaults.removeObject(forKey: kCURRENTACCOUNT)
    }

//    static func saveCurrentImage(_ image: UIImage) {
//        if let data = image.jpegData(compressionQuality: photoCompressionQuality),
//           let encoded = try? PropertyListEncoder().encode(data) {
//            UserDefaults.standard.set(encoded, forKey: kCURRENTIMAGEURL)
//        }
//    }
//
//    static func loadCurrentImage() -> UIImage? {
//        if let data = UserDefaults.standard.data(forKey: kCURRENTIMAGEURL),
//           let decoded = try? PropertyListDecoder().decode(Data.self, from: data),
//           let image = UIImage(data: decoded) {
//            LOGD("Finished loading current image from UserDefaults", from: self)
//            return image
//        }
//        LOGE("Loading current image", from: self)
//        return nil
//    }
}
