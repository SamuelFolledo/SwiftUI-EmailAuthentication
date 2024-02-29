//
//  AccountViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/23/24.
//

import SwiftUI

@Observable
class AccountViewModel: BaseViewModel {
    var account: Account

    var isViewingMode: Bool = true
    var selectedImage: UIImage? = nil {
        didSet {
            if isViewingMode && selectedImage != nil {
                ///If there's a new photo and we are not in editing mode, go to editing mode
                isViewingMode = false
            }
        }
    }
    var usernameFieldText: String = ""
    var usernameFieldHasError: Bool = false
    var usernameFieldIsActive: Bool = false
    var isDeleteAccountAlertPresented: Bool = false
    private var isRecentlyAuthenticated = false
    var isReauthenticationAlertPresented = false
    var password = ""

    //MARK: - Initializer
    init(account: Account) {
        self.account = account
    }

    override func onAppear() {
        super.onAppear()
        selectedImage = nil
        isViewingMode = true
        usernameFieldText = Account.current?.username ?? ""
    }

    //MARK: - Public Methods
    func logOut() {
        Task {
            do {
                updateLoadingMessage(to: Str.loggingOut)
                try await AccountNetworkManager.logOut()
                transitionToAuthenticationView()
                updateLoadingMessage(to: Str.updatingUser)
                try await AccountNetworkManager.setData(account: account)
                updateLoadingMessage(to: Str.savingUser)
                try await AccountManager.saveCurrent(account)
                updateError(nil)
            } catch {
                updateError(MainError(type: .logOut, message: error.localizedDescription))
            }
        }
    }

    ///Delete in Auth, Firestore, Storage, and then locally
    func deleteAccount() {
        Task {
            let currentUserId = account.id ?? Account.current?.userId ?? account.userId
            do {
                updateLoadingMessage(to: Str.deletingStoredPhoto)
                try await AccountNetworkManager.deleteStoredPhoto(currentUserId)
                updateLoadingMessage(to: Str.deletingData)
                try await AccountNetworkManager.deleteData(currentUserId)
                updateLoadingMessage(to: Str.deletingUsername)
                try await AccountNetworkManager.deleteUsername(account.username!)
                updateLoadingMessage(to: Str.deletingUser)
                try await AccountNetworkManager.deleteAuthData(userId: currentUserId)
                AccountManager.deleteCurrent()
                updateError(nil)
                account.reset()
                account.status = .logOut
            } catch {
                updateError(MainError(type: .deletingUser, message: error.localizedDescription))
            }
        }
    }

    func deleteButtonTapped() {
        if isRecentlyAuthenticated {
            isDeleteAccountAlertPresented = true
        } else {
            isReauthenticationAlertPresented = true
        }
    }

    func editSaveButtonTapped() {
        if isViewingMode {
            if isRecentlyAuthenticated {
                isViewingMode = false
            } else {
                isReauthenticationAlertPresented = true
            }
        } else {
            saveUser()
        }
    }

    func reauthenticateUser() {
        guard !isRecentlyAuthenticated else { return }
        Task {
            do {
                updateLoadingMessage(to: Str.reauthenticatingAccount)
                try await AccountNetworkManager.reauthenticateUser(password: password)
                isRecentlyAuthenticated = true
                updateError(nil)
                TODO("After logging in, edit should go to edit, delete shoud delete the account")
            } catch {
                updateError(MainError(type: .reauthenticatingUser, message: error.localizedDescription))
            }
        }
    }
}

//MARK: - Private Methods
private extension AccountViewModel {
    func transitionToAuthenticationView() {
        account.status = .logOut
        AccountManager.saveCurrent(account)
    }

    func saveUser() {
        let username = usernameFieldText.trimmed
        usernameFieldHasError = !username.isValidUsername
        guard !username.isEmpty,
              !usernameFieldHasError else {
            return updateError(MainError(type: .invalidUsername))
        }
        Task {
            ///Update username if needed
            var newUsername: String? = nil
            let didChangeUsername = username.lowercased() != account.displayName.trimmed.lowercased()
            if didChangeUsername {
                ///Check if username is unique
                if try await !AccountNetworkManager.isUnique(username: username) {
                    updateError(MainError(type: .notUniqueUsername))
                    return
                }
                ///Delete old username
                updateLoadingMessage(to: Str.deletingUsername)
                try await AccountNetworkManager.deleteUsername(account.username!)
                newUsername = username
                account.username = newUsername
            }

            ///If there's any photo changes, set account's photo in Storage and save the photo URL
            var newPhotoUrl: URL? = nil
            if let selectedImage {
                updateLoadingMessage(to: Str.storingPhoto)
                if let photoUrl = try await AccountNetworkManager.storePhoto(selectedImage, for: account.userId) {
                    newPhotoUrl = photoUrl
                    account.photoUrl = newPhotoUrl
                }
            }

            if newUsername != nil || newPhotoUrl != nil {
                ///Update authenticated user's displayName and photoUrl
                updateLoadingMessage(to: Str.updatingAuthenticatedUser)
                try await AccountNetworkManager.updateAuthenticatedUser(username: newUsername, photoUrl: newPhotoUrl)
            }

            ///Update database if there are any changes
            if didChangeUsername || newPhotoUrl != nil {
                if didChangeUsername {
                    updateLoadingMessage(to: Str.updatingUsername)
                    try await AccountNetworkManager.setUsername(username, userId: account.userId, email: account.email)
                }
                updateLoadingMessage(to: Str.savingUser)
                try await AccountNetworkManager.setData(account: account)
                try await AccountManager.saveCurrent(account)
            }
            try await auth.currentUser?.reload()
            LOGD("Successfully editted user with \(auth.currentUser!.displayName!) and \(auth.currentUser!.email!)")
            updateError(nil)
            selectedImage = nil
            isViewingMode = true
        }
    }
}
