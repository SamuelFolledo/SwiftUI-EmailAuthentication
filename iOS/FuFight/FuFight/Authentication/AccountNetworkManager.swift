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
    typealias UserCompletionHandler = (_ user: User?, _ error: Error?) -> Void
    typealias PhotoUrlCompletionHandler = (_ url: URL?, _ error: Error?) -> Void
    typealias CompletionHandler = (_ error: Error?) -> Void

    ///Create a user from email and password.
    ///Email and password should have been validated already before calling this method
    static func createUser(email: String, password: String, completion: @escaping UserCompletionHandler) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error {
                return completion(nil, error)
            }
            if let result {
                if let user = self.userFromAuthResult(result) {
                    return completion(user, nil)
                } else {
                    return completion(nil, NetworkError.invalidUser)
                }
            }
            completion(nil, NetworkError.noResult)
        }
    }

    ///Uploads the image to Storage for the userId passed
    static func storeImage(_ image: Image, for userId: String, completion: @escaping PhotoUrlCompletionHandler) {
        let imageData = image.toData(compression: 0.3)
        let metaData: StorageMetadata = StorageMetadata()
        metaData.contentType = "image/jpg"
        let photoReference = profilePhotoStorage.child("\(userId).jpg")
        photoReference.putData(imageData, metadata: metaData) { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                photoReference.downloadURL { url, error in
                    completion(url, error)
                    if url == nil && error == nil {
                        fatalError("Error: storeImage() is expecting a download url or an error")
                    }
                }
            }
        }
    }

    static func updateAuthenticatedUser(username: String, photoURL: URL, completion: @escaping CompletionHandler) {
        guard !username.isEmpty && !photoURL.absoluteString.isEmpty else {
            fatalError("Error updating authenticated user's username to \(username), and photoUrl to \(photoURL)")
        }
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.photoURL = photoURL
        changeRequest?.commitChanges(completion: { error in
            completion(error)
        })
    }

    static func setData(user: User?, merge: Bool = true, completion: @escaping CompletionHandler) {
        if let user {
            let userRef = db.collection(kUSER).document(user.userId)
            do {
                try userRef.setData(from: user, merge: merge)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
}

private extension AccountNetworkManager {
    static func userFromAuthResult(_ result: AuthDataResult) -> User? {
        return User(authResult: result)
    }
}
