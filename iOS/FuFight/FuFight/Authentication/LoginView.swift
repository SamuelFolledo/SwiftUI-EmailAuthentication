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
                VStack(spacing: 0) {
                    profilePicture()

                    VStack(spacing: 12) {
                        fields

                        buttons
                    }

                    Spacer()

                }
                .padding()
            }
            .navigationBarTitle(vm.step.title, displayMode: .large)
            .safeAreaInset(edge: .bottom) {
                if vm.step == .logIn || vm.step == .signUp {
                    bottomButton
                }
            }
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
            TappableImageView()
                .frame(idealWidth: 200, idealHeight: 200)
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

    var buttons: some View {
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
        UnderlinedTextField(type: vm.step.topFieldType, text: $vm.topFieldText, hasError: $vm.topFieldHasError)
    }

    var bottomField: some View {
        UnderlinedTextField(type: vm.step.bottomFieldType, text: $vm.bottomFieldText, hasError: $vm.bottomFieldHasError, isSecure: true)
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
        .padding(.bottom)
    }
}


#Preview {
    LoginView(vm: AuthenticationViewModel(step: .logIn))
}
