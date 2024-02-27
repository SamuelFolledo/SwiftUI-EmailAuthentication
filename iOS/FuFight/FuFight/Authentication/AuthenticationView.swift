//
//  AuthenticationView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct AuthenticationView: View {
    @State var vm: AuthenticationViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    profilePicture()

                    VStack(spacing: 12) {
                        fields

                        HStack {
                            rememberMeButton

                            Spacer()

                            if vm.step == .logIn {
                                forgetPasswordButton
                            }
                        }

                        authButtons
                    }

                    Spacer()
                }
                .allowsHitTesting(vm.loadingMessage == nil)
            }
            .navigationBarTitle(vm.step.title, displayMode: .large)
            .safeAreaInset(edge: .bottom) {
                if vm.step == .logIn || vm.step == .signUp {
                    bottomButton
                }
            }
            .overlay {
                if let message = vm.loadingMessage {
                    ProgressView(message)
                }
            }
            .alert(Str.forgotPasswordTitleQuestion, isPresented: $vm.showForgotPassword) {
                TextField(Str.enterYourEmail, text: $vm.topFieldText)
                Button(Str.cancelTitle) {
                    vm.showForgotPassword = false
                }
                Button(Str.submitTitle) {
                    vm.requestPasswordReset()
                }
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }

    @ViewBuilder func profilePicture() -> some View {
        if vm.step == .onboard {
            AccountImagePicker(selectedImage: $vm.selectedImage, url: .constant(nil))
                .padding()
        }
    }

    var fields: some View {
        VStack {
            switch vm.step {
            case .logIn, .phoneVerification, .signUp:
                topField

                bottomField
            case .phone, .onboard:
                topField
            }
        }
    }

    var rememberMeButton: some View {
        Button(action: {
            vm.rememberMe = !vm.rememberMe
        }) {
            HStack {
                Image(uiImage: vm.rememberMe ? checkedImage : uncheckedImage)
                    .renderingMode(.template)
                    .foregroundColor(.label)

                Text(Str.rememberMe)
                    .background(.clear)
                    .foregroundColor(Color.label)
                    .fontWeight(.semibold)
            }
        }
        .padding()
    }

    var forgetPasswordButton: some View {
        Button(action: {
            vm.showForgotPassword = true
        }) {
            Text(Str.forgotPasswordTitleQuestion)
                .background(.clear)
                .foregroundColor(Color.systemBlue)
                .fontWeight(.medium)
        }
        .padding()
    }

    var authButtons: some View {
        VStack {
            switch vm.step {
            case .logIn:
                topButton

                //TODO: Add Google, Facebook, Apple buttons
            case .phone, .phoneVerification, .signUp, .onboard:
                topButton
            }
        }
    }

    var topField: some View {
        UnderlinedTextField(
            type: $vm.topFieldType,
            text: $vm.topFieldText,
            hasError: $vm.topFieldHasError,
            isActive: $vm.topFieldIsActive) {
                TODO("TODO: CHECK USERNAME HERE")
                TODO("Add an action for top field's trailing button. Step: \(vm.step), and type: \(vm.topFieldType)")
            }
        .onSubmit {
            vm.onTopFieldReturnButtonTapped()
        }
        .padding(.horizontal)
    }

    var bottomField: some View {
        UnderlinedTextField(
            type: $vm.bottomFieldType,
            text: $vm.bottomFieldText,
            hasError: $vm.bottomFieldHasError,
            isActive: $vm.bottomFieldIsActive) {
                TODO("Add an action for bottom field's trailing button. Step: \(vm.step), and type: \(vm.bottomFieldType)")
            }
        .onSubmit {
            vm.onBottomFieldReturnButtonTapped()
        }
        .padding(.horizontal)
    }

    var topButton: some View {
        Button(action: {
            vm.topButtonTapped()
        }) {
            Text(vm.step.topButtonTitle)
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
        }
        .appButton(.system)
        .padding(.horizontal, 8)
        .disabled(!vm.topButtonIsEnabled)
    }

    var bottomButton: some View {
        Button(action: {
            vm.bottomButtonTapped()
        }) {
            Text(vm.step.bottomButtonTitle)
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .appButton(.tertiary)
    }
}


#Preview {
    AuthenticationView(vm: AuthenticationViewModel(step: .logIn, account: Account()))
}
