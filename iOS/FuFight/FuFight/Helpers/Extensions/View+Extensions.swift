//
//  View+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/18/24.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
