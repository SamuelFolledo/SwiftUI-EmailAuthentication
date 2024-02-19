//
//  TappableImageView.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/17/24.
//

import SwiftUI
import PhotosUI

struct TappableImageView: View {
    @State private var photosPickerPresented = false
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @Binding var selectedImage: Image

    var body: some View {
        VStack {
            selectedImage
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    selectedPhotos.removeAll()
                    photosPickerPresented.toggle()
                }
        }
        .photosPicker(isPresented: $photosPickerPresented, selection: $selectedPhotos)
        .onChange(of: selectedPhotos) {
            Task {
                selectedImages.removeAll()
                for item in selectedPhotos {
                    if let image = try? await item.loadTransferable(type: Image.self) {
                        selectedImages.append(image)
                    }
                }
                self.selectedImage = selectedImages.last ?? defaultProfilePhoto
            }
        }
    }
}
