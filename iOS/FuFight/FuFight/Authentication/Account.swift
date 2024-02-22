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
    @Published var imageUrl: URL?
    @Published private(set) var email: String?
    @Published private(set) var phoneNumber: String?
    @Published private(set) var createdAt: Date?
    @Published var status: Account.Status = .unfinished
    
    //TODO: Remove or implement this profilePhoto
    var profilePhoto: UIImage = kDEFAULTACCOUNTIMAGE
    var userId: String {
        return id!
    }
    var displayName: String {
        return username ?? ""
    }
    static var current: Account? {
        if let account = AccountManager.getCurrent() {
            return account
        } else if let firUser = auth.currentUser { //TODO: fetch database
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
        self.imageUrl = authResult.user.photoURL
        self.createdAt = authResult.user.metadata.creationDate
        self.id = authResult.user.uid
    }

    init(_ firUser: User) {
        self.id = firUser.uid
        self.username = firUser.displayName
        self.imageUrl = firUser.photoURL
        self.email = firUser.email
        self.phoneNumber = firUser.phoneNumber
        self.createdAt = firUser.metadata.creationDate
    }

    deinit { }

    //MARK: - Codable overrides
    private enum CodingKeys : String, CodingKey {
        case id, username, imageUrl, email, phoneNumber, createdAt, status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(email, forKey: .email)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(status.rawValue, forKey: .status)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id)
        self.username = try values.decodeIfPresent(String.self, forKey: .username)!
        self.imageUrl = try values.decodeIfPresent(URL.self, forKey: .imageUrl)!
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
        if let imageUrl = user.imageUrl {
            self.imageUrl = imageUrl
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
        //TODO: Uncomment line below or remove the need for this method
//        self.profilePhoto = user.profilePhoto
//        self.status = user.status
    }

    func reset() {
        //setting username to empty will remove the Delete account button on AuthenticationView
        username = ""
    }

//MARK: Class Functions
//    class func currentId() -> String {
//        return Auth.auth().currentUser!.uid
//    }
//    
//    class func currentAccount() -> Account? {
////        if let user = auth.currentAccount {
////        }
////        if Auth.auth().currentAccount != nil { //if we have user...
////            if let dictionary = AccountDefaults.standard.object(forKey: kCURRENTACCOUNT) {
////                return Account.init(dictionary: dictionary as! [String: Any])
////            }
////        }
//        return nil //if we dont have user in our AccountDefaults, then return nil
//    }
//    
//MARK: Email Authentication
    class func registerAccountWith(email: String, password: String, completion: @escaping (_ error: String?, _ user: Account?) -> Void) { //do u think I should return the user here on completion?
        auth.createUser(withEmail: email, password: password) { (firAccount, error) in
            if let error = error {
                completion(error.localizedDescription,nil)
            }
//            guard let user = firAccount?.user else {
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
//                    }
//                }
//            }
        }
    }
    
//MARK: Logout
    class func logOutCurrentAccount(withBlock: (_ success: Bool) -> Void) {
        UserDefaults.standard.removeObject(forKey: kCURRENTACCOUNT)
        UserDefaults.standard.synchronize() //save the changes
        do {
            try Auth.auth().signOut()
            deleteProfilePhoto()
            withBlock(true)
        } catch {
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
                firDatabase.child(kREGISTEREDACCOUNTS).child(user!.email!.emailEncryptedForFirebase()).removeValue { (error, ref) in //remove email reference in kREGISTEREDACCOUNTS as well
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
//    if Account.currentAccount() != nil {
//        return true
//    } else {
//        return false
//    }
    true
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

//MARK: - Custom Account Classes
extension Account {
    enum Status: Int {
        case valid
        ///When account is created but unfinished
        case unfinished
        case logOut
    }
}
