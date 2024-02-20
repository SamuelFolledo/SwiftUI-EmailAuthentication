//
//  AccountNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

enum NetworkError: Error {
    ///When there is no error but there is no expected result as well
    case noResult
    case timeout(message: String)
    ///Used when a Account class cannot be created from Firebase's Auth Account
    case invalidAccount
}

class AccountNetworkManager {
    private init() {}

    ///Create a user from email and password
    ///Email and password should have been validated already before calling this method
    static func createAccount(email: String, password: String) async throws -> AuthDataResult? {
        do {
            let authData = try await auth.createUser(withEmail: email, password: password)
            return authData
        } catch {
            throw error
        }
    }

    ///Uploads the image to Storage for the userId passed
    static func storeImage(_ image: UIImage, compressionQuality: Double = 0.3, for userId: String) async throws -> URL? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        let metaData: StorageMetadata = StorageMetadata()
        metaData.contentType = "image/jpg"
        let photoReference = profilePhotoStorage.child("\(userId).jpg")
        do {
            let _ = try await photoReference.putDataAsync(imageData, metadata: metaData)
            let url = try await photoReference.downloadURL()
            return url
        } catch {
            throw error
        }
    }

    ///Update current account's information on Auth.auth()
    static func updateAuthenticatedAccount(username: String, photoURL: URL) async throws {
        guard !username.isEmpty && !photoURL.absoluteString.isEmpty else {
            fatalError("Error updating authenticated account's username to \(username), and photoUrl to \(photoURL)")
        }
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.photoURL = photoURL
        do {
            try await changeRequest?.commitChanges()
        } catch {
            throw error
        }
    }

    ///Update user's data on the databaes. Set merge to false to override existing data
    static func setData(account: Account?, merge: Bool = true) async throws {
        if let account {
            let accountRef = db.collection(kACCOUNT).document(account.userId)
            do {
                try accountRef.setData(from: account, merge: merge)
            } catch {
                throw error
            }
        }
    }
}

private extension AccountNetworkManager { }
