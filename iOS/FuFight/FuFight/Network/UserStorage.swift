//
//  UserStorage.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 1/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

///method that grabs an image, and user's id to save it to, compress it as JPEG, store in Storage, and returning the URL if no error
func getImageURL(id: String, image: UIImage, completion: @escaping(_ imageURL: String?, _ error: String?) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
    let metaData: StorageMetadata = StorageMetadata()
    metaData.contentType = "image/jpg" //set its type
    let imageReference = Storage.storage().reference().child(kUSER).child(kPROFILEIMAGE).child("\(id).jpg")
    imageReference.putData(imageData, metadata: metaData, completion: { (metadata, error) in //putData = Asynchronously uploads data to the reference
        if let error = error {
            completion(nil, error.localizedDescription)
        } else {
            imageReference.downloadURL(completion: { (imageUrl, error) in
                if let error = error {
                    completion(nil, error.localizedDescription)
                } else {
                    guard let url = imageUrl?.absoluteString else { return }
                    completion(url, nil)
                }
            })
        }
    })
}

///fetch user's image given a URL. Can return an error
func getUserImage(imageUrl: String, completion: @escaping (_ error: String?, _ image: UIImage?) -> Void) {
    guard let url = URL(string: imageUrl) else {
        completion("No image url found", nil)
        return
    }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
    guard
        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
        //let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
        let data = data, error == nil,
        let image = UIImage(data: data)
        else {
            completion("No image found", nil)
            return
        }
        DispatchQueue.main.async {
            completion(nil, image)
        }
    }.resume()
}
