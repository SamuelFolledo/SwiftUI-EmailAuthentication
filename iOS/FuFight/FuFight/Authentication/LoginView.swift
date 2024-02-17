//
//  LoginView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct LoginView: View {
    @State var vm: AuthenticationViewModel

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
            .navigationBarTitle(vm.step.title, displayMode: .large)
        }
    }

    var fields: some View {
        VStack {
            switch vm.step {
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
            switch vm.step {
            case .login, .signup:
                topButton

                bottomButton
            case .phone, .phoneVerification:
                topButton
            }
        }
    }

    var usernameField: some View {
        UnderlinedTextField(placeholder: Str.usernameTitle, text: $vm.username)
                .textInputAutocapitalization(.words)
    }

    var topField: some View {
        UnderlinedTextField(placeholder: vm.step.topFieldPlaceholder, text: $vm.topFieldText)
            .keyboardType(vm.step.topFieldKeyboardType)
    }

    var bottomField: some View {
        UnderlinedTextField(placeholder: vm.step.bottomFieldPlaceholder,  text: $vm.bottomFieldText, isSecure: true)
            .keyboardType(vm.step.bottomFieldKeyboardType)
    }

    var topButton: some View {
        Button(action: {
            vm.topButtonTapped()
        }) {
            Text(vm.step.topButtonTitle)
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
            vm.bottomButtonTapped()
        }) {
            Text(vm.step.bottomButtonTitle)
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
    LoginView(vm: AuthenticationViewModel(step: .login))
}
