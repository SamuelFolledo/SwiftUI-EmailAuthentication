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
                if let message = vm.loadingMessage {
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
        .allowsHitTesting(vm.loadingMessage == nil)
    }

    var accountImage: some View {
        NavigationLink(destination: AccountView(vm: AccountViewModel(account: vm.account))) {
            AccountImageView(url: vm.account.photoUrl, radius: 30)
        }
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: Account()))
}
