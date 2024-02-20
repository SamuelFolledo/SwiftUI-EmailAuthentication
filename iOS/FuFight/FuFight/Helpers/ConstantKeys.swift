//
//  Constants.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import Foundation
import UIKit
import FirebaseDatabase

public let firDatabase = Database.database().reference()
public let kVERIFICATIONCODE = "firebase_verification" //for phone auth

//ids and keys for one signal
public let kONESIGNALAPPID: String = "586d3ef3-6411-41d0-ab81-2a797a16a50b"
public let kONESIGNALID: String = "OneSignalId"
public let kUSERID: String = "userId"
public let kUSERNAME: String = "username"
public let kFIRSTNAME: String = "firstName"
public let kLASTNAME: String = "lastName"
public let kFULLNAME: String = "fullName"
public let kEMAIL: String = "email"
public let kIMAGEURL: String = "imageUrl"
public let kCURRENTUSER: String = "currentUser" //for userDefaults
public let kUSERIMAGE: String = "userImage"
public let kAUTHTYPES: String = "authenticationTypes"
public let kPHONEAUTH: String = "phoneAuth"
public let kEMAILAUTH: String = "emailAuth"
public let kFACEBOOKAUTH: String = "facebookAuth"
public let kGMAILAUTH: String = "gmailAuth"
public let kANONYMOUSAUTH: String = "anonymousAuth"
public let kAPPLEAUTH: String = "appleAuth"

//Other properties for user
public let kUSER: String = "user"
public let kMESSAGES: String = "message"
public let kPUSHID: String = "pushId"
public let kPROFILEPHOTO: String = "profilePhoto"

//MARK: Other Constants
public let kCREATEDAT: String = "createdAt"
public let kUPDATEDAT: String = "updatedAt"

//storyboard VC Identifiers
public let kHOMEVIEWCONTROLLER: String = "homeVC"
public let kPREGAMEVIEWCONTROLLER: String = "preGameVC"
public let kGAMEVIEWCONTROLLER: String = "gameVC"
public let kGAMEOVERVIEWCONTROLLER: String = "gameOverVC"
public let kGAMEHISTORYVIEWCONTROLLER: String = "gameHistoryVC"
public let kGAMEHISTORYCELL: String = "gameHistoryCell"

//User info
public let kGAMESTATS: String = "gameStats" //this is for Firebase/users/uid/gameStats
public let kWINLOSESTAT: String = "winLoseStat"
public let kWINS: String = "wins"
public let kLOSES: String = "loses"
public let kMATCHESUID: String = "matchesUid"
public let kMATCHESDICTIONARY: String = "matchesDictionary"
public let kEXPERIENCES: String = "experiences"
public let kMAXEXPERIENCE: String = "maxExperience"
public let kLEVEL: String = "level"
public let kRESULT: String = "result"
public let kOPPONENTUID: String = "opponentUid"

public let kREDCGCOLOR = UIColor.red.cgColor
public let kCLEARCGCOLOR = UIColor.clear.cgColor
public let kGREENCGCOLOR = UIColor.green.cgColor

//fonts
public let kHEADERTEXT: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

//controller storyboard id
public let kCHATCONTROLLER: String = "chatController"
public let kLOGINCONTROLLER: String = "logInController"
public let kANIMATIONCONTROLLER: String = "animationController"
public let kMENUCONTROLLER: String = "menuController"

public let kREGISTEREDUSERS: String = "registeredUsers"
public let kPHONENUMBER: String = "phoneNumber"

public let kFINISHREGISTRATIONVC: String = "finishRegistrationVC"
public let kAUTHENTICATIONVC: String = "authenticationVC"

//Storyboard Identifiers
public let kTOAUTHENTICATIONVC: String = "toAuthenticationVC"
public let kTONAMEVC: String = "toNameVC"
public let kTOAUTHMENUVC: String = "toAuthMenuVC"

//images
public let kDEFAULTPROFILEIMAGE: UIImage = UIImage(systemName: "person")!
//public let kBLANKIMAGE: UIImage = UIImage(named: "blankImage")!
//public let kCORRECTIMAGE: UIImage = UIImage(named: "correct")!
//public let kWRONGIMAGE: UIImage = UIImage(named: "wrong")!