//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct HomeView: View {
    @State var vm: HomeViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {

                    Text("Welcome \(vm.account.displayName)")

                    Spacer()

                    Button("Play") {
                        TODO("Play")
                    }
                }
                .alert(title: vm.alertTitle, message: vm.alertMessage, isPresented: $vm.isAlertPresented)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        accountImage
                    }
                }
            }
            .overlay {
                if let message = vm.loadingMessage {
                    ProgressView(message)
                }
            }
        }
        .navigationTitle("Welcome \(vm.account.displayName)")
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImage(url: vm.account.photoUrl, radius: 30)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: Account()))
}
