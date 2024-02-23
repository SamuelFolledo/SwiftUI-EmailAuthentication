//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State var vm: HomeViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {

                    Text("Welcome Home")

                    Spacer()

                    Button("Play") {
                        TODO("Play")
                    }
                }
                .alert(title: vm.error?.title ?? "", message: vm.error?.message ?? "", isPresented: $vm.hasError)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        accountImage
                    }
                }
            }
            .overlay {
                if let message = vm.globalLoadingMessage {
                    ProgressView(message)
                }
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.globalLoadingMessage == nil)
    }

    var accountImage: some View {
        Menu {
            //TODO: Use for each
            Button("Update Profile Picture", action: vm.editPhoto)
            Button("Logout", action: vm.logOut)
            Button("Delete Account", action: vm.deleteAccount)
        } label: {
            AccountImageView(url: vm.account.photoUrl, radius: 30)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: Account()))
}
