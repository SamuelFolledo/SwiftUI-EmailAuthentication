//
//  AccountImagePicker.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import SwiftUI
import PhotosUI

///An ImageView that can show PhotosPicker to update the image
struct AccountImagePicker: View {
    @State private var selectedPhoto: PhotosPickerItem?
    ///set this to nil in order to show the image from url
    @Binding var selectedImage: UIImage?
    @Binding var url: URL?

    let radius: CGFloat = 200

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .screenshots, .panoramas])) {
                Group {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                    } else {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fill)
                .clipShape(Circle())
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                if let selectedPhoto,
                   let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                    self.selectedImage = UIImage(data: data) ?? defaultProfilePhoto
                    self.selectedPhoto = nil
                }
            }
        }
    }
}
