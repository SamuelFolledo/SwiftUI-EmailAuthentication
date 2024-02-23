//
//  Account.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class Account: ObservableObject, Codable {
    @DocumentID var id: String?
    @Published var username: String?
    @Published var photoUrl: URL?
    @Published private(set) var email: String?
    @Published private(set) var phoneNumber: String?
    @Published private(set) var createdAt: Date?
    @Published var status: Account.Status = .unfinished

    var userId: String {
        return id!
    }
    var displayName: String {
        return username ?? ""
    }
    ///Returns the currently signed in Account
    static var current: Account? {
        if let account = AccountManager.getCurrent() {
            return account
        } else if let firUser = auth.currentUser {
            return Account(firUser)
        }
        return nil
    }

    //MARK: - Initializers
    init() { }

    ///Initializer for sign up only
    convenience init(_ authResult: AuthDataResult) {
        self.init()
        self.email = authResult.user.email
        self.phoneNumber = authResult.user.phoneNumber
        self.username = authResult.user.displayName
        self.photoUrl = authResult.user.photoURL
        self.createdAt = authResult.user.metadata.creationDate
        self.id = authResult.user.uid
    }

    init(_ firUser: User) {
        self.id = firUser.uid
        self.username = firUser.displayName
        self.photoUrl = firUser.photoURL
        self.email = firUser.email
        self.phoneNumber = firUser.phoneNumber
        self.createdAt = firUser.metadata.creationDate
    }

    deinit { }

    //MARK: - Codable overrides
    private enum CodingKeys : String, CodingKey {
        case id, username, photoUrl, email, phoneNumber, createdAt, status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(photoUrl, forKey: .photoUrl)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(status.rawValue, forKey: .status)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id)
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.photoUrl = try values.decodeIfPresent(URL.self, forKey: .photoUrl)!
        self.email = try values.decodeIfPresent(String.self, forKey: .email)!
        self.phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)!
        let statusRawValue = try values.decodeIfPresent(Int.self, forKey: .status)!
        self.status = Status(rawValue: statusRawValue) ?? .unfinished
    }

    //MARK: Public Methods

    func update(with user: Account) {
        if let id = user.id {
            self.id = id
        }
        if let username = user.username {
            self.username = username
        }
        if let photoUrl = user.photoUrl {
            self.photoUrl = photoUrl
        }
        if let email = user.email {
            self.email = email
        }
        if let phoneNumber = user.phoneNumber {
            self.phoneNumber = phoneNumber
        }
        if let createdAt = user.createdAt {
            self.createdAt = createdAt
        }
    }

    func reset() {
        //setting username to empty will remove the Delete account button on AuthenticationView
        username = ""
    }
}

//MARK: - Custom Account Classes
extension Account {
    enum Status: Int {
        case valid
        ///When account is created but unfinished
        case unfinished
        case logOut
    }
}
