//
//  Logger.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/20/24.
//

import Foundation

fileprivate func log(_ type: LogType, message: String, from: AnyClass? = nil) {
    if let from {
        print("\(type.rawValue):[\(from.description())]: \(type.rawValue):\(message)")
    } else {
        print("\(type.rawValue):\(message)")
    }
}

fileprivate enum LogType: String {
    case error = "LOGE"
    case debugError = "LOGDE"
    case log = "LOG"
    case debugLog = "LOGD"
    case todo = "TODO"
}

//MARK: - Public Methods

func TODO(_ message: String, from: AnyClass? = nil) {
    log(.todo, message: message, from: from)
}

///Logs for both production and development environments
func LOG(_ message: String, from: AnyClass? = nil) {
    log(.log, message: message, from: from)
}

///Error logs
func LOGE(_ message: String, from: AnyClass? = nil) {
    log(.error, message: message, from: from)
}

///Logs for development environments only
func LOGD(_ message: String, from: AnyClass? = nil) {
    log(.debugLog, message: message, from: from)
}

///Error logs for development environments only
func LOGDE(_ message: String, from: AnyClass? = nil) {
    log(.debugError, message: message, from: from)
}
