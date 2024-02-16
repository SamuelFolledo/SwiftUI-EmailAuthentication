//
//  UnderlinedTextField.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
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
