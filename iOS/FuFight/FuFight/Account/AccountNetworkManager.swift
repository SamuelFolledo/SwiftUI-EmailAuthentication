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
}

//MARK: - Authentication Extension
extension AccountNetworkManager {
    ///Create a user from email and password
    ///Email and password should have been validated already before calling this method
    static func createUser(email: String, password: String) async throws -> AuthDataResult? {
        do {
            let authData = try await auth.createUser(withEmail: email, password: password)
            LOGD("AUTH: Finished creating user from email: \(authData.user.email ?? "")", from: self)
            return authData
        } catch {
            throw error
        }
    }

    ///Deletes and log out the current authenticated user
    static func deleteAuthData(userId: String) async throws {
        do {
            try await auth.currentUser?.delete()
            LOGD("AUTH: Finished deleting and logging out the authenticated user with userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }

    static func logIn(email: String, password: String) async throws -> AuthDataResult? {
        do {
            let authData = try await auth.signIn(withEmail: email, password: password)
            LOGD("AUTH: Finished loggin in for \(authData.user.displayName ?? "")", from: self)
            return authData
        } catch {
            throw error
        }
    }

    static func logOut() async throws {
        do {
            try auth.signOut()
            LOGD("AUTH: Finished logging out", from: self)
        } catch {
            throw error
        }
    }

    static func resetPassword(withEmail email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            LOGD("AUTH: Finished resetPassword link to \(email)", from: self)
        } catch {
            throw error
        }
    }

    static func reauthenticateUser(password: String) async throws {
        do {
            let email = Account.current?.email ?? auth.currentUser?.email ?? Defaults.savedEmail
            let credential = EmailAuthProvider.credential(withEmail: email.trimmed, password: password)
            try await auth.currentUser?.reauthenticate(with: credential)
            LOGD("AUTH: Finished reauthenticating user withEmail: \(email)", from: self)
        } catch {
            throw error
        }
    }

    static func updatePassword(_ password: String) async throws {
        do {
            try await auth.currentUser?.updatePassword(to: password)
            LOGD("AUTH: Finished updating user's password", from: self)
        } catch {
            throw error
        }
    }

    ///Update current account's username and/or photUrl
    static func updateAuthenticatedUser(username: String? = nil, photoUrl: URL? = nil) async throws {
        let username = (username ?? "").trimmed
        let photoUrlString = (photoUrl?.absoluteString ?? "").trimmed
        let hasUsername = !username.isEmpty
        let hasPhotoUrl = !photoUrlString.isEmpty
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        if hasUsername {
            LOGD("Updating authenticated user's username to \(username)")
            changeRequest?.displayName = username
        }
        if hasPhotoUrl {
            LOGD("Updating authenticated user's photoUrl to \(photoUrlString)")
            changeRequest?.photoURL = photoUrl
        }
        do {
            try await changeRequest?.commitChanges()
            LOGD("AUTH: Finished updating user's displayName to \(username) and photoUrl to \(photoUrlString)", from: self)
        } catch {
            throw error
        }
    }
}

//MARK: - Storage Extension
extension AccountNetworkManager {
    ///Uploads the image to Storage for the userId passed
    static func storePhoto(_ image: UIImage, for userId: String) async throws -> URL? {
        guard let imageData = image.jpegData(compressionQuality: accountPhotoCompressionQuality) else { return nil }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let photoReference = accountPhotoStorage.child("\(userId).jpg")
        do {
            let _ = try await photoReference.putDataAsync(imageData, metadata: metaData)
            let url = try await photoReference.downloadURL()
            LOGD("STORAGE: Finished storing account's profile photo with downloadUrl: \(url.absoluteString)", from: self)
            return url
        } catch {
            throw error
        }
    }

    static func deleteStoredPhoto(_ userId: String) async throws {
        let photoReference = accountPhotoStorage.child("\(userId).jpg")
        do {
            try await photoReference.delete()
            LOGD("STORAGE: Finished deleting profile photo from userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }
}

//MARK: - Firestore Database Extension
extension AccountNetworkManager {
    ///Update user's data on the database. Set merge to false to override existing data
    static func setData(account: Account?, merge: Bool = true) async throws {
        if let account {
            let accountsRef = accountsDb.document(account.userId)
            do {
                try accountsRef.setData(from: account, merge: merge)
                LOGD("DB: Finished setData for \(account.displayName)", from: self)
            } catch {
                throw error
            }
        }
    }

    ///fetch user's data from Firestore and returns an account
    static func fetchData(userId: String) async throws -> Account? {
        let accountsRef = accountsDb.document(userId)
        do {
            let account = try await accountsRef.getDocument(as: Account.self)
            LOGD("DB: Finished fetching \(account.displayName)", from: self)
            return account
        } catch {
            throw error
        }
    }

    ///Delete user's data from Accounts collection
    static func deleteData(_ userId: String) async throws {
        do {
            let accountsRef = accountsDb.document(userId)
            try await accountsRef.delete()
            LOGD("DB: Finished deleting account with userId: \(userId)", from: self)
        } catch {
            throw error
        }
    }

    ///Set username to the database into both Accounts and Username collections
    static func setUsername(_ username: String, userId: String, email: String? = nil) async throws {
        let username = username.trimmed
        guard !userId.isEmpty,
              !username.isEmpty else { return }
        do {
            ///Update Accounts collection
            let accountsRef = accountsDb.document(userId)
            try await accountsRef.setData([kUSERNAME: username], merge: true)
            ///Update Usernames collection
            let loweredUsername = username.lowercased()
            var data: [String: Any] = [kUSERID: userId, kUSERNAME: username]
            if let email {
                data[kEMAIL] = email.trimmed
            }
            let usernameRef = usernamesDb.document(loweredUsername)
            try await usernameRef.setData(data, merge: true)
        } catch {
            throw error
        }
    }

    ///Delete user's data from Usernames collection
    static func deleteUsername(_ username: String) async throws {
        do {
            let loweredUsername = username.trimmed.lowercased()
            let usernameRef = usernamesDb.document(loweredUsername)
            try await usernameRef.delete()
            LOGD("DB: Finished deleting account in Usernames collection username: \(username)", from: self)
        } catch {
            throw error
        }
    }

    ///Check Users collection in database if username is unique
    static func isUnique(username: String) async throws -> Bool {
        do {
            let loweredUsername = username.trimmed.lowercased()
            let document = try await usernamesDb.document(loweredUsername).getDocument()
            let isUnique = !document.exists
            LOGD("DB: Username \(username) is unique = \(isUnique)", from: self)
            return isUnique
        } catch {
            throw error
        }
    }

    ///Fetch the email from Usernames collection
    static func fetchEmailFrom(username: String) async throws -> String? {
        do {
            let loweredUsername = username.trimmed.lowercased()
            let document = try await usernamesDb.document(loweredUsername).getDocument()
            if document.exists,
               let usernameData = document.data(),
               let email = usernameData[kEMAIL] as? String {
                LOGD("DB: Finished fetching email \(email) from username \(username)", from: self)
                return email
            }
            return nil
        } catch {
            throw error
        }
    }

    ///Returns true if user has completed onboarding
    static func isAccountValid(userId: String) async throws -> Bool {
        do {
            let accountsRef = accountsDb.document(userId)
            return try await accountsRef.getDocument().exists
        } catch {
            throw error
        }
    }
}
