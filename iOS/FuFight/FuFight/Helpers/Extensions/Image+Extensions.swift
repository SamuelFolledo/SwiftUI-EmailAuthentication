//
//  Image+Extensions.swift
//  FuFight
//
//  Created by Samuel Folledo on 2/19/24.
//

import SwiftUI

extension Image {
    ///Turns an Image to a data. Compression passed should range from 0-1
    func toData(compression: Double = 1) -> Data {
        return self.toUIImage().jpegData(compressionQuality: compression)!
    }

    func save(for name: String) {
        UserDefaults.standard.setValue(self.toData(), forKey: name)
    }
}
