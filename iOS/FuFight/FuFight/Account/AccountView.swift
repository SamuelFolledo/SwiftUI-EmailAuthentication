//
//  AccountView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

struct AccountView: View {
    @State var vm: AccountViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profilePicture

                VStack(spacing: 12) {
                    usernameField

                    emailField

                    Spacer()

                    changePasswordButton

                    deleteAccountButton

                    logOutButton
                }
            }
            .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
            .alert(title: Str.deleteAccountQuestion, primaryButton: AlertButton(type: .delete, action: vm.deleteAccount), secondaryButton: AlertButton(type: .secondaryCancel), isPresented: $vm.isDeleteAccountAlertPresented)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
        }
        .overlay {
            if let message = vm.loadingMessage {
                ProgressView(message)
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var saveButton: some View {
        Button(action: vm.saveButtonTapped) {
            Text(Str.saveTitle)
        }
        .appButton(.tertiary)
    }
    var profilePicture: some View {
        TappableImageView(selectedImage: $vm.selectedImage)
            .frame(idealWidth: 200, idealHeight: 200)
            .clipShape(Circle())
            .padding()
    }
    var usernameField: some View {
        UnderlinedTextField(
            type: .constant(.username),
            text: $vm.usernameFieldText,
            hasError: $vm.usernameFieldHasError,
            isActive: $vm.usernameFieldIsActive) {
                TODO("TODO: CHECK USERNAME HERE")
            }
            .onSubmit {
                vm.usernameFieldIsActive = false
            }
            .padding(.horizontal)
    }
    var emailField: some View {
        UnderlinedTextField(
            type: .constant(.email),
            text: $vm.emailFieldText,
            hasError: $vm.emailFieldHasError,
            isActive: $vm.emailFieldIsActive)
            .onSubmit {
                vm.emailFieldIsActive = false
            }
            .padding(.horizontal)
    }
    var changePasswordButton: some View {
        Button(action: vm.saveButtonTapped) {
            Text(Str.updatePasswordTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.primary)
    }
    var deleteAccountButton: some View {
        Button {
            vm.isDeleteAccountAlertPresented = true
        } label: {
            Text(Str.deleteTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.destructive)
    }
    var logOutButton: some View {
        Button(action: vm.logOut) {
            Text(Str.logOutTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.destructive, isBordered: true)
    }
}

#Preview {
    NavigationView {
        AccountView(vm: AccountViewModel(account: Account()))
    }
}
