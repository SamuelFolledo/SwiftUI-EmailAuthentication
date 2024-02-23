//
//  Constants.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

let auth = Auth.auth()
let db = Firestore.firestore()
let accountDb = db.collection(kACCOUNTS)
let storage = Storage.storage().reference()
let accountPhotoStorage = storage.child(kACCOUNTS).child(kPHOTOS)

let accountPhotoCompressionQuality: Double = 0.3

//Constant images
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
let checkedImage: UIImage = UIImage(systemName: "checkmark.square.fill")!
let uncheckedImage: UIImage = UIImage(systemName: "square")!
public let kDEFAULTACCOUNTIMAGE: UIImage = UIImage(systemName: "person")!
