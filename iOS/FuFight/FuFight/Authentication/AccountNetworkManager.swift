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
    ///Used when a User class cannot be created from Firebase's Auth User
    case invalidUser
}

class AccountNetworkManager {
    private init() {}

    ///Create a user from email and password.
    ///Email and password should have been validated already before calling this method
    static func createUser(email: String, password: String) async throws -> User? {
        do {
            let authDataResult = try await auth.createUser(withEmail: email, password: password)
            return User(authResult: authDataResult)
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

    ///Update current user's information on Auth.auth()
    static func updateAuthenticatedUser(username: String, photoURL: URL) async throws {
        guard !username.isEmpty && !photoURL.absoluteString.isEmpty else {
            fatalError("Error updating authenticated user's username to \(username), and photoUrl to \(photoURL)")
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
    static func setData(user: User?, merge: Bool = true) async throws {
        if let user {
            let userRef = db.collection(kUSER).document(user.userId)
            do {
                try userRef.setData(from: user, merge: merge)
            } catch {
                throw error
            }
        }
    }
}

private extension AccountNetworkManager { }
