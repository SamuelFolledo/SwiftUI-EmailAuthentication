//
//  UnderlinedTextField.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct UnderlinedTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding()
            .textFieldStyle(PlainTextFieldStyle())
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            Rectangle().frame(height: 1).padding(.horizontal)
        }
    }
}
