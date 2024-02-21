//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var vm: HomeViewModel

    var body: some View {
        VStack {
            homeNavBar

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")

            Spacer()
        }
        .padding()
        .onAppear {
            vm.onAppear()
        }
        .onDisappear {
            vm.onDisappear()
        }
    }

    var homeNavBar: some View {
        VStack {
            HStack {
                accountImage

                Spacer()

                logoutButton
            }
        }
        .ignoresSafeArea()
    }

    var accountImage: some View {
        AsyncImage(url: vm.account.imageUrl) { image in
            image
                .resizable()
                .frame(width: 50, height: 50)
        } placeholder: {
            ProgressView()
        }
    }

    var logoutButton: some View {
        Button(action: {
            vm.logOut()
        }) {
            Text("Log out")
                .padding()
                .background(.clear)
                .foregroundColor(Color.systemBlue)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(account: Account()))
}
