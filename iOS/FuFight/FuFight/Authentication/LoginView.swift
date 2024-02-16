//
//  LoginView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: AuthenticationViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    fields

                    buttons

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle(viewModel.step.title, displayMode: .large)
        }
    }

    var fields: some View {
        VStack {
            switch viewModel.step {
            case .login, .phoneVerification:
                topField

                bottomField
            case .signup:
                usernameField

                topField

                bottomField
            case .phone:
                topField
            }
        }
    }

    var buttons: some View {
        VStack {
            switch viewModel.step {
            case .login, .signup:
                topButton

                bottomButton
            case .phone, .phoneVerification:
                topButton
            }
        }
    }

    var usernameField: some View {
        UnderlinedTextField(placeholder: Str.usernameTitle, text: $viewModel.username)
                .textInputAutocapitalization(.words)
    }

    var topField: some View {
        UnderlinedTextField(placeholder: viewModel.step.topFieldPlaceholder, text: $viewModel.topFieldText)
            .keyboardType(viewModel.step.topFieldKeyboardType)
    }

    var bottomField: some View {
        UnderlinedTextField(placeholder: viewModel.step.bottomFieldPlaceholder,  text: $viewModel.bottomFieldText, isSecure: true)
            .keyboardType(viewModel.step.bottomFieldKeyboardType)
    }

    var topButton: some View {
        Button(action: {
            viewModel.topButtonTapped()
        }) {
            Text(viewModel.step.topButtonTitle)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    var bottomButton: some View {
        Button(action: {
            viewModel.bottomButtonTapped()
        }) {
            Text(viewModel.step.bottomButtonTitle)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal)

    }
}


#Preview {
    LoginView(viewModel: AuthenticationViewModel(step: .login))
}
