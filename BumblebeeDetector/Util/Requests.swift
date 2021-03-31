//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//  snippets adapted from https://www.donnywals.com/uploading-images-and-forms-to-a-server-using-urlsession/

import UIKit
import Alamofire

class Requests {
    static func sendImages(images: [UIImage], completion: @escaping (_ json: Any?)->()) {
        let url = URL(string: "http://3.249.81.168/api/image")!
        let selectedImages = selectionMethod(images: images)
        
        // upload the images
        AF.upload(multipartFormData: { (multipartFormData) in
            for (index, image) in selectedImages.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    multipartFormData.append(imageData, withName: "image\(index)", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
                }
            }
        }, to: url).responseJSON { response in
            completion(response.value)
        }
    }
    
    /// Selects which images will be sent to the API
    static func selectionMethod(images: [UIImage]) -> [UIImage] {
        // temporarily just send one
        return Array(images.prefix(1))
    }
}
