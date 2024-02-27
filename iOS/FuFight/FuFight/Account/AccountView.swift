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
                    editSaveButton
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

    var editSaveButton: some View {
        Button(action: vm.editSaveButtonTapped) {
            Text(vm.isViewingMode ? Str.editTitle : Str.saveTitle)
        }
        .appButton(.tertiary)
    }
    var profilePicture: some View {
        AccountImagePicker(selectedImage: $vm.selectedImage, url: $vm.account.photoUrl)
            .frame(width: 200, height: 200)
            .padding()
    }
    var usernameField: some View {
        UnderlinedTextField(
            type: .constant(.username),
            text: $vm.usernameFieldText,
            hasError: $vm.usernameFieldHasError,
            isActive: $vm.usernameFieldIsActive, 
            isDisabled: $vm.isViewingMode) {
                TODO("TODO: CHECK USERNAME HERE")
            }
            .onSubmit {
                vm.usernameFieldIsActive = false
            }
    }
    var emailField: some View {
        UnderlinedTextField(
            type: .constant(.email),
            text: $vm.emailFieldText,
            hasError: $vm.emailFieldHasError,
            isActive: $vm.emailFieldIsActive, 
            isDisabled: $vm.isViewingMode)
            .onSubmit {
                vm.emailFieldIsActive = false
            }
    }
    var changePasswordButton: some View {
        Button(action: vm.editSaveButtonTapped) {
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
