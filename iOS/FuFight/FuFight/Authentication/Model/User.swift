//
//  User.swift
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

enum AccountStatus {
    case valid
    ///When user is created but unfinished
    case unfinished
    case logout
}

//MARK: - UserPublicInfo
class UserPublicInfo: UserPrivateInfo {
    var username: String?
    var imageUrl: URL?

    init(email: String?, phoneNumber: String?, username: String, imageUrl: URL? = nil, createdAt: Date, updatedAt: Date = Date()) {
        self.username = username
        self.imageUrl = imageUrl
        super.init(email: email, phoneNumber: phoneNumber, createdAt: createdAt, updatedAt: updatedAt)
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
}

//MARK: - UserPrivateInfo
class UserPrivateInfo: Codable {
    var email: String?
    var phoneNumber: String?
    var createdAt: Date
    var updatedAt: Date

    init(email: String? = nil, phoneNumber: String? = nil, createdAt: Date, updatedAt: Date = Date()) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

//MARK: - User
class User: UserPublicInfo, ObservableObject {
    @DocumentID var id: String?
    var profilePhoto: UIImage = kDEFAULTPROFILEIMAGE
    @Published var accountStatus: AccountStatus = .unfinished
    var userId: String {
        return id ?? "fakeId"
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
        let user = Auth.auth().currentUser
        if let user = user {
            super.init(email: user.email, phoneNumber: user.phoneNumber, username: user.displayName ?? "", imageUrl: user.photoURL, createdAt: Date(), updatedAt: Date())
            self.id = user.uid
        } else {
            super.init(email: "fakeEmail", phoneNumber: "fakePhoneNumber", username: "fakeUsername", imageUrl: URL(string: "fakeImageUrl"), createdAt: Date(), updatedAt: Date())
            self.id = "fakeUserId"
        }
    }

    init(authResult: AuthDataResult) {
        super.init(email: authResult.user.email, phoneNumber: authResult.user.phoneNumber, username: authResult.user.displayName ?? "", imageUrl: authResult.user.photoURL, createdAt: Date(), updatedAt: Date())
        self.id = authResult.user.uid
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    deinit {
        print("User \(displayName) is being deinitialize.")
    }

    func update(with user: User) {
        self.id = user.id
        self.username = user.username
        self.imageUrl = user.imageUrl
        self.email = user.email
        self.phoneNumber = user.phoneNumber
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
        self.profilePhoto = user.profilePhoto
        self.accountStatus = user.accountStatus
    }

//MARK: Class Functions
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> User? {
//        if let user = auth.currentUser {
//            print("TODO: Implement returning a current user")
//        }
//        if Auth.auth().currentUser != nil { //if we have user...
//            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
//                return User.init(dictionary: dictionary as! [String: Any])
//            }
//        }
        return nil //if we dont have user in our UserDefaults, then return nil
    }
    
//MARK: Email Authentication
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) { //do u think I should return the user here on completion?
        Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                completion(error.localizedDescription,nil)
            }
//            guard let user = firUser?.user else {
//                print("User not found after attempt to register")
//                completion(("User not found after attempt to register"), nil)
//                return }
//            let currentUser = User(userId: user.uid, username: "", firstName: "", lastName: "", email: email, phoneNumber: "", imageUrl: "", authTypes: [AuthType.email], createdAt: Date(), updatedAt: Date())
//            registerUserEmailIntoDatabase(user: currentUser) { (error, user) in
//                if let error = error {
//                    completion(error.localizedDescription, nil)
//                }
//                completion(nil, user!)
//            }
        }
    }
    
    class func logInUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (userDetails, error) in
            if let error = error {
                completion(error)
                return
            }
//            guard let userDetails = userDetails else { return }
//            if userDetails.additionalUserInfo!.isNewUser { //if new user
//                let user: User = User(userId: userDetails.user.uid, username: "", firstName: "", lastName: "", email: email, phoneNumber: "", imageUrl: "", authTypes: [.email], createdAt: Date(), updatedAt: Date())
//                saveUserLocally(user: user)
//                saveUserInBackground(user: user)
//                saveEmailInDatabase(email: user.email ?? "")
//                completion(nil)
//            } else { //if not user's first time...
//                fetchUserWith(userId: userDetails.user.uid) { (user) in
//                    if let user = user {
//                        user.updatedAt = Date()
//                        saveUserLocally(user: user)
//                        saveUserInBackground(user: user)
//                        completion(nil)
//                    } else {
//                        print("No user fetched from \(String(describing: userDetails.user.email))")
//                    }
//                }
//            }
        }
    }
    
//MARK: Logout
    class func logOutCurrentUser(withBlock: (_ success: Bool) -> Void) {
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
    
    class func deleteUser(completion: @escaping(_ error: Error?) -> Void) { //delete the current user
        let user = Auth.auth().currentUser
        let userRef = firDatabase.child(kUSER).queryOrdered(byChild: kUSERID).queryEqual(toValue: user!.uid).queryLimited(toFirst: 1)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in //delete from Database
            if snapshot.exists() { //snapshot has uid and all its user's values
                firDatabase.child(kUSER).child(user!.uid).removeValue { (error, ref) in
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
    
    class func updateCurrentUser(values: [String:Any], completion: @escaping (_ error: String?) -> Void) { //update anything but userID
//        guard let user = self.currentUser() else { return }
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
//        saveUserLocally(user: user)
//        saveUserInBackground(user: user)
        completion(nil)
    }
}

//MARK: User Codable Extension
extension User {
//    private enum CodingKeys : String, CodingKey {
//        case id, username, email, imageUrl, phoneNumber, createdAt, updatedAt, accountStatus
//    }
//
//    override func encode(to encoder: Encoder) throws {
////        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(username, forKey: .username)
//        try container.encode(imageUrl, forKey: .imageUrl)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(updatedAt, forKey: .updatedAt)
//        try container.encode(email, forKey: .email)
//        try container.encode(phoneNumber, forKey: .phoneNumber)
//    }
}

//MARK: Helper Methods for User
func userDictionaryFrom(user: User) -> NSDictionary { //take a user and return an NSDictionary, convert dates into strings
//    let createdAt = Service.dateFormatter().string(from: user.createdAt) //convert dates to strings first
//    let updatedAt = Service.dateFormatter().string(from: user.updatedAt)
//    let authTypes: [String] = authTypesToString(types: user.authTypes)
//    return NSDictionary(
//        objects: [user.userId, user.username, user.firstName ?? "", user.lastName ?? "", user.fullName, user.email ?? "", user.phoneNumber ?? "", user.imageUrl ?? "", createdAt, updatedAt, authTypes],
//        forKeys: [kUSERID as NSCopying, kUSERNAME as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kPHONENUMBER as NSCopying, kIMAGEURL as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kAUTHTYPES as NSCopying])
    return [:]
}

func isUserLoggedIn() -> Bool { //checks if we have user logged in
    if User.currentUser() != nil {
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
