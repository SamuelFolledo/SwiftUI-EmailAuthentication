//
//  AccountImageView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/21/24.
//

import SwiftUI

struct AccountImageView: View {
    let url: URL?
    let radius: CGFloat
    let circleColor: Color = .gray
    var squareSide: CGFloat {
        2.0.squareRoot() * radius
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(circleColor)
//                .frame(width: radius * 2, height: radius * 2)
                .frame(width: squareSide, height: squareSide)

            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(width: squareSide, height: squareSide)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
            }
        }
    }
}
