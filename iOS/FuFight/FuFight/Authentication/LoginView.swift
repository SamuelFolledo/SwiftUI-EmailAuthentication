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
            TappableImageView(selectedImage: $vm.selectedImage)
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
        UnderlinedTextField(type: vm.step.topFieldType, text: $vm.topFieldText, hasError: $vm.topFieldHasError, isActive: $vm.topFieldIsActive)
            .onSubmit {
                vm.onTopFieldSubmit()
            }
    }

    var bottomField: some View {
        UnderlinedTextField(type: vm.step.bottomFieldType, text: $vm.bottomFieldText, hasError: $vm.bottomFieldHasError, isActive: $vm.bottomFieldIsActive, isSecure: true)
            .onSubmit {
                vm.onBottomFieldSubmit()
            }
    }

    var topButton: some View {
        Button(action: {
            vm.topButtonTapped()
        }) {
            Text(vm.step.topButtonTitle)
                .padding()
                .foregroundColor(!vm.topButtonIsEnabled ? .systemGray5 : .white)
        }
        .frame(maxWidth: .infinity)
        .background(!vm.topButtonIsEnabled ? .systemGray : Color.blue)
        .disabled(!vm.topButtonIsEnabled)
        .cornerRadius(8)
        .padding(.horizontal)
        .opacity(!vm.topButtonIsEnabled ? 0.8 : 1)
    }

    var bottomButton: some View {
        Button(action: {
            vm.bottomButtonTapped()
        }) {
            Text(vm.step.bottomButtonTitle)
                .padding()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}


#Preview {
    LoginView(vm: AuthenticationViewModel(step: .logIn))
}
