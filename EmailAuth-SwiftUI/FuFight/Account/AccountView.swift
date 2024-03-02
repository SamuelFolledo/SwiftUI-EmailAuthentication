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
            .alert(title: vm.alertTitle, 
                   message: vm.alertMessage,
                   isPresented: $vm.isAlertPresented)
            .alert(title: Str.deleteAccountQuestion,
                   primaryButton: AlertButton(type: .delete, action: vm.deleteAccount), 
                   secondaryButton: AlertButton(type: .secondaryCancel), 
                   isPresented: $vm.isDeleteAccountAlertPresented)
            .alert(withText: $vm.password,
                   fieldType: .password(.current),
                   title: Str.logInAgainToMakeChanges,
                   primaryButton: AlertButton(title: Str.logInTitle, action: vm.reauthenticate),
                   isPresented: $vm.isReauthenticationAlertPresented)
            .padding(.horizontal, horizontalPadding)
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
            .frame(width: accountImagePickerHeight, height: accountImagePickerHeight)
            .padding()
    }
    var usernameField: some View {
        UnderlinedTextField(
            type: .constant(.username),
            text: $vm.usernameFieldText,
            hasError: $vm.usernameFieldHasError,
            isActive: $vm.usernameFieldIsActive, 
            isDisabled: $vm.isViewingMode) {
                TODO("Is username unique?")
            }
            .onSubmit {
                vm.usernameFieldIsActive = false
            }
    }
    var emailField: some View {
        UnderlinedTextField(
            type: .constant(.email),
            text: .constant(Account.current?.email ?? ""),
            isDisabled: .constant(true))
    }
    var changePasswordButton: some View {
        NavigationLink {
            UpdatePasswordView()
        } label: {
            Text(Str.changePasswordTitle)
                .frame(maxWidth: .infinity)
        }
        .appButton(.primary)
    }
    var deleteAccountButton: some View {
        Button(action: vm.deleteButtonTapped) {
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
