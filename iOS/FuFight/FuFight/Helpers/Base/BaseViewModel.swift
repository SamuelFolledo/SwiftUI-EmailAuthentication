//
//  BaseViewModel.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/25/24.
//

import Foundation

@Observable
class BaseViewModel: ViewModel {
    var isAlertPresented: Bool = false
    private(set) var alertTitle = ""
    private(set) var alertMessage = ""
    private(set) var error: MainError? {
        didSet {
            if let error {
                alertTitle = error.title
                alertMessage = error.message ?? ""
            }
        }
    }
    ///Set this to nil in order to remove this global loading indicator, empty string will show it but have empty message
    private(set) var loadingMessage: String? = nil

    //MARK: - ViewModel Overrides

    func onAppear() { }

    func onDisappear() { }

    func updateAlert(_ title: String, message: String) {
        alertTitle = title
        alertMessage = message
    }

    func updateError(_ error: MainError?) {
        updateLoadingMessage(to: nil)
        DispatchQueue.main.async {
            if let error {
                LOGE(error.fullMessage)
                self.error = error
                self.isAlertPresented = true
            } else {
                ///clear error messages
                self.isAlertPresented = false
                self.error = nil
            }
        }
    }

    func updateLoadingMessage(to message: String?) {
        DispatchQueue.main.async {
            self.loadingMessage = message
        }
    }
}
