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
    var usernameFieldText: String = Account.current?.username ?? ""
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

    override func onDisappear() {
        super.onDisappear()
        selectedImage = nil
        isViewingMode = true
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
            if !isRecentlyAuthenticated {
                isReauthenticationAlertPresented = true
                return
            }
        } else {
            saveUser()
        }
        isViewingMode = !isViewingMode
    }

    func reauthenticateUser() {
        guard !isRecentlyAuthenticated else { return }
        Task {
            do {
                updateLoadingMessage(to: Str.reauthenticatingAccount)
                try await AccountNetworkManager.reauthenticateUser(password: password)
                isRecentlyAuthenticated = true
                updateError(nil)
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
            ///If there's any photo changes, set account's photo in Storage and save the photo URL
            var newPhotoUrl: URL? = nil
            if let selectedImage {
                updateLoadingMessage(to: Str.storingPhoto)
                if let photoUrl = try await AccountNetworkManager.storePhoto(selectedImage, for: account.userId) {
                    newPhotoUrl = photoUrl
                    account.photoUrl = newPhotoUrl
                }
            }

            ///Update username if needed
            var newUsername: String? = nil
            let didChangeUsername = username.lowercased() != account.displayName.trimmed.lowercased()
            if didChangeUsername {
                ///Delete old username
                updateLoadingMessage(to: Str.deletingUsername)
                try await AccountNetworkManager.deleteUsername(account.username!)
                newUsername = username
                account.username = newUsername
            }
            if newUsername != nil || newPhotoUrl != nil {
                ///Update authenticated user's displayName and photoUrl
                updateLoadingMessage(to: Str.updatingAuthenticatedUser)
                try await AccountNetworkManager.updateAuthenticatedUser(username: newUsername, photoUrl: newPhotoUrl)
            }

            ///Save account if there are any changes
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
        }
    }
}
