//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//  snippets adapted from https://www.donnywals.com/uploading-images-and-forms-to-a-server-using-urlsession/

import UIKit
import Alamofire

class Requests {
    static func sendImages(images: [UIImage], imagesToSend: Int, completion: @escaping (_ json: Any?)->()) {
        let url = URL(string: "http://3.249.81.168/api/image")!
        let selectedImages = selectionMethod(images: images, howMany: imagesToSend)
        
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
    static func selectionMethod(images: [UIImage], howMany: Int) -> [UIImage] {
//        // calculate standard derivations of edges in the detections
//        let stDevs = ImageQuality().sequenceSharpnessStDev(images: images)
//        
//        // reorder the detections based on the st devs
//        let sorted = zip(stDevs, images).sorted { $0.0 > $1.0 }
//        let sharpestImages = sorted.map { $0.1 }
        
        // baseline: evenly spaced items
        let indices = Array(stride(from: 0, to: images.count-1, by: images.count/howMany))
        let selectedImages = indices.map { images[$0] }
        
        return selectedImages
    }
}
