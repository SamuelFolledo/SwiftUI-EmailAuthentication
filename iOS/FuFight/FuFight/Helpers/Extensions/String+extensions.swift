//
//  String+extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import UIKit

extension String {
    
    ///converts an email to a key that Firebase can accept. It first splits an email by "@", then convert "@" to a "_at_", and "_dot_" to a string
    func emailEncryptedForFirebase() -> String {
        let lastIndex = self.lastIndex(of: "@") //lastIndex because we want to search for @ from the end of the string //NOTE: make sure email being asked has @ symbol or it will crash
        let emailName = self.prefix(upTo: lastIndex!) //kobeBryant
        let emailDomain = self.suffix(from: lastIndex!) //@gmail.com
        let emailDomainWith_at_ = emailDomain.replacingOccurrences(of: "@", with: "_at_") //convert @ in emailDomain to _at_
        let newEmailDomain = emailDomainWith_at_.replacingOccurrences(of: ".", with: "_dot_") //conver all . in emailDomain to _dot_ //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }
    
    ///converts an encrypted email back to original email
    func emailDecryptedFromFirebase() -> String {
        let newEmail = self.replacingLastOccurrenceOfString("_at_", with: "@") //replace one occurence of _at_
        let lastIndex = newEmail.lastIndex(of: "@")
        let emailName = newEmail.prefix(upTo: lastIndex!)
        let emailDomain = newEmail.suffix(from: lastIndex!)
        let newEmailDomain = emailDomain.replacingOccurrences(of: "_dot_", with: ".") //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }

    /// replace the last occurence of the searchString argument with replacementString argument. Used to convert _at_ back to @
    func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String, caseInsensitive: Bool = true) -> String {
        let options: String.CompareOptions
        if caseInsensitive { //search backwards, or search backwards and case sensitive
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        if let range = self.range(of: searchString,
                options: options,
                range: nil,
                locale: nil) { //get the range of index of the characters in the searchString
            return self.replacingCharacters(in: range, with: replacementString) //replace searchString's range with the replacementString argument
        }
        return self
    }
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" //\\. is escape character for dot
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidName: Bool {
        let regex = "[A-Za-z]*[ ]?[A-Za-z]*[.]?[ ]?[A-Za-z]{1,30}" //regex for full name //will take the following name formats, Samuel || Samuel P. || Samuel P. Folledo || Samuel Folledo
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    var isValidUsername: Bool {
        let regex = "[A-Z0-9a-zâéè._+-]{1,15}" //regex for user name //accept any US characters, other characters, and symbols like (. _ + -)
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }

    ///validate Password
    var isValidPassword: Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        // least one symbol
        //  min 8 characters total
        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
    }

    ///Returns an array of error messages about what evaluation failed
    func getPasswordErrorMessages(str: String) -> [String] {
        var errors: [String] = []
        if(!NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: str)){
            errors.append("least one uppercase")
        }
        if(!NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: str)){
            errors.append("least one digit")
        }
        if(!NSPredicate(format:"SELF MATCHES %@", ".*[!&^%$#@()/]+.*").evaluate(with: str)){
            errors.append("least one symbol")
        }
        if(!NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: str)){
            errors.append("least one lowercase")
        }
        if(str.count < 8){
            errors.append("min 8 characters total")
        }
        return errors
    }

    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    ///returns string's without left and right white spaces or new lines
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

