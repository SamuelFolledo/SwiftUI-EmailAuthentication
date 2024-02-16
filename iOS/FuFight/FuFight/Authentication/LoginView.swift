//
//  LoginView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UnderlinedTextField(placeholder: "Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    UnderlinedTextField(placeholder: "Password", text: $password, isSecure: true)


                    UnderlinedTextField(placeholder: "Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)

                    Button(action: {
                        // Handle login with email and password
                    }) {
                        Text("Login")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        // Handle Google sign-in
                    }) {
                        Text("Sign in with Google")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Log In", displayMode: .large)
        }
    }
}


#Preview {
    LoginView()
}
