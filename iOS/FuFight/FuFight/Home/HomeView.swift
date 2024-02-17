//
//  HomeView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/15/24.
//

import SwiftUI

struct HomeView: View {
    var vm: HomeViewModel

    var body: some View {
        VStack {
            homeNavBar
                .ignoresSafeArea()

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")

            Spacer()
        }
        .padding()
    }

    var homeNavBar: some View {
        VStack {
            HStack {
                Spacer()

                logoutButton
            }
        }
    }

    var logoutButton: some View {
        Button(action: {
            vm.logout()
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
    HomeView(vm: HomeViewModel(user: User()))
}
