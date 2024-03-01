//
//  UpdatePasswordView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/26/24.
//

import SwiftUI

struct UpdatePasswordView: View {
    @State var vm = UpdatePasswordViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                VStack(spacing: 12) {
                    currentPasswordField

                    passwordField

                    confirmPasswordField

                    Spacer()
                }
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
            .padding(.vertical)
            .padding(.horizontal, horizontalPadding)
        }
        .overlay {
            if let message = vm.loadingMessage {
                ProgressView(message)
            }
        }
        .onAppear {
            vm.onAppear()
            vm.dismissAction = {
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
        .navigationTitle(Str.updatePasswordTitle)
        .safeAreaInset(edge: .bottom) {
            updatePasswordButton
        }
    }

    var currentPasswordField: some View {
        UnderlinedTextField(
            type: $vm.currentPasswordFieldType,
            text: $vm.currentPassword,
            isSecure: $vm.currentPasswordIsSecure,
            hasError: $vm.currentPasswordHasError,
            isActive: $vm.currentPasswordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.passwordIsActive = true
        }
    }
    var passwordField: some View {
        UnderlinedTextField(
            type: $vm.passwordFieldType,
            text: $vm.password,
            isSecure: $vm.passwordIsSecure,
            hasError: $vm.passwordHasError,
            isActive: $vm.passwordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.confirmPasswordIsActive = true
        }
    }
    var confirmPasswordField: some View {
        UnderlinedTextField(
            type: $vm.confirmPasswordFieldType,
            text: $vm.confirmPassword,
            isSecure: $vm.confirmPasswordIsSecure,
            hasError: $vm.confirmPasswordHasError,
            isActive: $vm.confirmPasswordIsActive,
            isDisabled: .constant(false))
        .onSubmit {
            vm.updatePasswordButtonTapped()
        }
    }
    var updatePasswordButton: some View {
        Button(action: vm.updatePasswordButtonTapped) {
            Text(Str.updatePasswordTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.primary)
        .disabled(!vm.isUpdatePasswordButtonEnabled)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, 8)
    }
}

#Preview {
    NavigationView {
        UpdatePasswordView(vm: UpdatePasswordViewModel())
    }
}
