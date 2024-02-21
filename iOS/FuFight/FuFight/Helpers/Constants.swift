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
let accountDb = db.collection(kACCOUNT)
let storage = Storage.storage().reference()
let profilePhotoStorage = storage.child(kACCOUNT).child(kPROFILEPHOTO)

let photoCompressionQuality: Double = 0.3
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
