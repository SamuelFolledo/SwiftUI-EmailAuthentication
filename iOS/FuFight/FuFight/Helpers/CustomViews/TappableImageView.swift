//
//  TappableImageView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import SwiftUI
import PhotosUI

struct TappableImageView: View {
//    @State var photoManager = PhotoManager() //Since photo permission is not needed for accessing photos, PhotoManager is not needed
    @State private var photosPickerPresented = false
    @State private var selectedPhoto: PhotosPickerItem?
    @Binding var selectedImage: UIImage

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .screenshots, .panoramas])) {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
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
