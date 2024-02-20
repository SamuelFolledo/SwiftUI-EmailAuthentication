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

//MARK: - Account
class Account: AccountPublicInfo, ObservableObject {
    @DocumentID var id: String?
    var profilePhoto: UIImage = kDEFAULTPROFILEIMAGE
    @Published var accountStatus: Account.Status = .unfinished
    var userId: String {
        return id!
    }
    var displayName: String {
        return username ?? ""
    }

    //MARK: - Codable overrides
    private enum CodingKeys : String, CodingKey {
        case id
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }

    //MARK: - Initializers
    init() {
        FirebaseApp.configure()
        if let user = auth.currentUser {
            super.init(email: user.email, phoneNumber: user.phoneNumber, username: user.displayName ?? "", imageUrl: user.photoURL, createdAt: nil)
            self.id = user.uid
        } else {
            super.init(email: nil, phoneNumber: nil, username: "", imageUrl: nil, createdAt: nil)
        }
    }

    init(_ authResult: AuthDataResult) {
        super.init(email: authResult.user.email, phoneNumber: authResult.user.phoneNumber, username: authResult.user.displayName ?? "", imageUrl: authResult.user.photoURL, createdAt: authResult.user.metadata.creationDate)
        self.id = authResult.user.uid
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    deinit {
        print("Account \(displayName) is being deinitialize.")
    }

    func update(with user: Account) {
        self.id = user.id
        self.update(username: user.username, imageUrl: user.imageUrl)
        self.update(email: user.email, phoneNumber: user.phoneNumber, createdAt: user.createdAt)
        self.profilePhoto = user.profilePhoto
        self.accountStatus = user.accountStatus
    }

//MARK: Class Functions
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentAccount() -> Account? {
//        if let user = auth.currentAccount {
//            print("TODO: Implement returning a current user")
//        }
//        if Auth.auth().currentAccount != nil { //if we have user...
//            if let dictionary = AccountDefaults.standard.object(forKey: kCURRENTUSER) {
//                return Account.init(dictionary: dictionary as! [String: Any])
//            }
//        }
        return nil //if we dont have user in our AccountDefaults, then return nil
    }
    
//MARK: Email Authentication
    class func registerAccountWith(email: String, password: String, completion: @escaping (_ error: String?, _ user: Account?) -> Void) { //do u think I should return the user here on completion?
        auth.createUser(withEmail: email, password: password) { (firAccount, error) in
            if let error = error {
                completion(error.localizedDescription,nil)
            }
//            guard let user = firAccount?.user else {
//                print("Account not found after attempt to register")
//                completion(("Account not found after attempt to register"), nil)
//                return }
//            let currentAccount = Account(userId: user.uid, username: "", firstName: "", lastName: "", email: email, phoneNumber: "", imageUrl: "", authTypes: [AuthType.email], createdAt: Date())
//            registerAccountEmailIntoDatabase(user: currentAccount) { (error, user) in
//                if let error = error {
//                    completion(error.localizedDescription, nil)
//                }
//                completion(nil, user!)
//            }
        }
    }
    
    class func logInAccountWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (userDetails, error) in
            if let error = error {
                completion(error)
                return
            }
//            guard let userDetails = userDetails else { return }
//            if userDetails.additionalAccountInfo!.isNewAccount { //if new user
//                let user: Account = Account(userId: userDetails.user.uid, username: "", firstName: "", lastName: "", email: email, phoneNumber: "", imageUrl: "", authTypes: [.email], createdAt: Date())
//                saveAccountLocally(user: user)
//                saveAccountInBackground(user: user)
//                saveEmailInDatabase(email: user.email ?? "")
//                completion(nil)
//            } else { //if not user's first time...
//                fetchAccountWith(userId: userDetails.user.uid) { (user) in
//                    if let user = user {
//                        saveAccountLocally(user: user)
//                        saveAccountInBackground(user: user)
//                        completion(nil)
//                    } else {
//                        print("No user fetched from \(String(describing: userDetails.user.email))")
//                    }
//                }
//            }
        }
    }
    
//MARK: Logout
    class func logOutCurrentAccount(withBlock: (_ success: Bool) -> Void) {
        print("Logging outttt...")
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize() //save the changes
        do {
            try Auth.auth().signOut()
            deleteProfilePhoto()
            withBlock(true)
        } catch let error as NSError {
            print("error logging out \(error.localizedDescription)")
            withBlock(false)
        }
    }
    
    class func deleteAccount(completion: @escaping(_ error: Error?) -> Void) { //delete the current user
        let user = auth.currentUser
        let userRef = firDatabase.child(kACCOUNT).queryOrdered(byChild: kUSERID).queryEqual(toValue: user!.uid).queryLimited(toFirst: 1)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in //delete from Database
            if snapshot.exists() { //snapshot has uid and all its user's values
                firDatabase.child(kACCOUNT).child(user!.uid).removeValue { (error, ref) in
                    completion(error)
                }
                firDatabase.child(kREGISTEREDUSERS).child(user!.email!.emailEncryptedForFirebase()).removeValue { (error, ref) in //remove email reference in kREGISTEREDUSERS as well
                    completion(error)
                }
            }
        }, withCancel: nil)
        user?.delete(completion: { (error) in //delete from Authentication
            completion(error)
        })
    }
    
    class func updateCurrentAccount(values: [String:Any], completion: @escaping (_ error: String?) -> Void) { //update anything but userID
//        guard let user = self.currentAccount() else { return }
//        if let username = values[kUSERNAME] {
//            user.username = username as! String
//        }
//        if let firstName = values[kFIRSTNAME] {
//            user.firstName = firstName as? String
//        }
//        if let lastName = values[kLASTNAME] {
//            user.lastName = lastName as? String
//        }
//        user.fullName = createFullNameFrom(first: user.firstName, last: user.lastName)
//        if let email = values[kEMAIL] {
//            user.email = email as? String
//        }
//        if let imageUrl = values[kIMAGEURL] {
//            user.imageUrl = imageUrl as? String
//        }
//        saveAccountLocally(user: user)
//        saveAccountInBackground(user: user)
        completion(nil)
    }
}

//MARK: Account Codable Extension
extension Account {
//    private enum CodingKeys : String, CodingKey {
//        case id, username, email, imageUrl, phoneNumber, createdAt, accountStatus
//    }
//
//    override func encode(to encoder: Encoder) throws {
////        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(username, forKey: .username)
//        try container.encode(imageUrl, forKey: .imageUrl)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(email, forKey: .email)
//        try container.encode(phoneNumber, forKey: .phoneNumber)
//    }
}

//MARK: Helper Methods for Account
func userDictionaryFrom(user: Account) -> NSDictionary { //take a user and return an NSDictionary, convert dates into strings
//    let createdAt = Service.dateFormatter().string(from: user.createdAt) //convert dates to strings first
//    let authTypes: [String] = authTypesToString(types: user.authTypes)
//    return NSDictionary(
//        objects: [user.userId, user.username, user.firstName ?? "", user.lastName ?? "", user.fullName, user.email ?? "", user.phoneNumber ?? "", user.imageUrl ?? "", createdAt, authTypes],
//        forKeys: [kUSERID as NSCopying, kUSERNAME as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kPHONENUMBER as NSCopying, kIMAGEURL as NSCopying, kCREATEDAT as NSCopying, kAUTHTYPES as NSCopying])
    return [:]
}

func isAccountLoggedIn() -> Bool { //checks if we have user logged in
    if Account.currentAccount() != nil {
        return true
    } else {
        return false
    }
}

func saveProfilePhoto(id: String = kPROFILEPHOTO, profilePhoto: UIImage) {
    let imageData: Data = profilePhoto.jpegData(compressionQuality: 0.2)!
    UserDefaults.standard.set(imageData, forKey: id)
    UserDefaults.standard.synchronize()
}

func loadProfilePhoto(id: String = kPROFILEPHOTO) -> UIImage? {
    return UIImage(data: UserDefaults.standard.data(forKey: id)!)
}

func deleteProfilePhoto(id: String = kPROFILEPHOTO) {
    UserDefaults.standard.removeObject(forKey: id)
    UserDefaults.standard.synchronize()
}

//MARK: - Account Classes
extension Account {
    enum Status {
        case valid
        ///When account is created but unfinished
        case unfinished
        case logout
    }
}

class AccountPublicInfo: AccountPrivateInfo {
    private(set) var username: String?
    private(set) var imageUrl: URL?

    init(email: String?, phoneNumber: String?, username: String, imageUrl: URL? = nil, createdAt: Date?) {
        self.username = username
        self.imageUrl = imageUrl
        super.init(email: email, phoneNumber: phoneNumber, createdAt: createdAt)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    //MARK: - Codable
    private enum CodingKeys : String, CodingKey {
        case userId, username, email, imageUrl, phoneNumber, accountStatus
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
    }

    func update(username: String? = nil, imageUrl: URL? = nil) {
        if let username {
            self.username = username
        }
        if let imageUrl {
            self.imageUrl = imageUrl
        }
    }
}

class AccountPrivateInfo: Codable {
    private(set) var email: String?
    private(set) var phoneNumber: String?
    private(set) var createdAt: Date?

    init(email: String? = nil, phoneNumber: String? = nil, createdAt: Date?) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }

    func update(email: String? = nil, phoneNumber: String? = nil, createdAt: Date? = nil) {
        if let email {
            self.email = email
        }
        if let phoneNumber {
            self.phoneNumber = phoneNumber
        }
        if let createdAt {
            self.createdAt = createdAt
        }
    }
}
