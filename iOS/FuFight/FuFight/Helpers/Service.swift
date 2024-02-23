//
//  Service.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import UIKit

class Service {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }

    private let dateFormat = "yyyyMMddHHmmss"
    static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Service().dateFormat
        return dateFormatter
    }
}
