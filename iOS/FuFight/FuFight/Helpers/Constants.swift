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
let storage = Storage.storage().reference()
let profilePhotoStorage = storage.child(kUSER).child(kPROFILEPHOTO)

//let defaultProfilePhoto = Image(systemName: "person.crop.circle")
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
