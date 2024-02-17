//
//  AccountNetworkManager.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum NetworkError: Error {
    ///When there is no error but there is no expected result as well
    case noResult
    case timeout(message: String)
    ///Used when a User class cannot be created from Firebase's Auth User
    case invalidUser
}

class AccountNetworkManager {
    typealias UserCompletionHandler = (_ user: User?, _ error: Error?) -> Void

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
}

private extension AccountNetworkManager {
    static func userFromAuthResult(_ result: AuthDataResult) -> User? {
        return User(authResult: result)
    }
}
