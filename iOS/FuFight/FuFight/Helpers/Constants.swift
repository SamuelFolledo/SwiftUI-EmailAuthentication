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

//MARK: Firebase Auth constants
let auth = Auth.auth()

//MARK: Firebase Firestore database constants
let db = Firestore.firestore()
let accountsDb = db.collection(kACCOUNTS)
let usernamesDb = db.collection(kUSERNAMES)

//MARK: Firebase Storage constants
let storage = Storage.storage().reference()
let accountPhotoStorage = storage.child(kACCOUNTS).child(kPHOTOS)

//Fonts
let defaultFontSize: CGFloat = 16
let smallTitleFont = Font.system(size: defaultFontSize + 4, weight: .bold)
let textFont = Font.system(size: defaultFontSize, weight: .regular)
let mediumTextFont = textFont.weight(.medium)
let boldedTextFont = textFont.weight(.bold)
let buttonFont = Font.system(size: defaultFontSize, weight: .semibold)
let boldedButtonFont = buttonFont.weight(.bold)

//Constant images
let defaultProfilePhoto: UIImage = UIImage(systemName: "person.crop.circle")!
let checkedImage: UIImage = UIImage(systemName: "checkmark.square.fill")!
let uncheckedImage: UIImage = UIImage(systemName: "square")!
let securedImage: some View = Image(systemName: "eye")
    .foregroundColor(.label)
let nonSecuredImage: some View = Image(systemName: "eye.slash")
    .foregroundColor(.label)
let invalidImage: some View = Image(systemName: "xmark.circle.fill")
    .foregroundColor(Color.systemRed)
let validImage: some View = Image(systemName: "checkmark.circle.fill")
    .foregroundColor(Color.systemGreen)
let accountPhotoCompressionQuality: Double = 0.3
let horizontalPadding: CGFloat = 36
let accountImagePickerHeight: CGFloat = 160
