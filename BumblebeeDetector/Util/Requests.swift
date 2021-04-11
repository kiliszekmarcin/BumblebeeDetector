//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//  snippets adapted from https://www.donnywals.com/uploading-images-and-forms-to-a-server-using-urlsession/

import UIKit
import Alamofire

class Requests {
    static func sendImages(images: [UIImage], imagesToSend: Int, method: Method, completion: @escaping (_ json: Any?)->()) -> [UIImage] {
        let url = URL(string: "http://3.249.81.168/api/image")!
        let selectedImages = selectionMethod(images: images, howMany: imagesToSend, method: method)
        
        // upload the images
        AF.upload(multipartFormData: { (multipartFormData) in
            for (index, image) in selectedImages.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    multipartFormData.append(imageData, withName: "image\(index)", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
                }
            }
        }, to: url).responseJSON { response in
            switch (response.result) {
            case .success:
                completion(response.value)
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    //timeout here
                }
                print("\n\nRequest failed with error:\n \(error)")
                
                completion(["error" : error.localizedDescription])
                break
            }
        }
        
        return selectedImages
    }
    
    /// Selects which images will be sent to the API
    static func selectionMethod(images: [UIImage], howMany: Int, method: Method) -> [UIImage] {
        // calculate standard derivations of edges in the detections
        let stDevs = ImageQuality().sequenceSharpnessStDev(images: images)
        
        switch method {
        case .evenlySpaced:
            // baseline: evenly spaced items
            let indices = Array(stride(from: 0, to: images.count-1, by: images.count/howMany))
            let selectedImages = indices.map { images[$0] }

            return selectedImages
        case .highestStDev:
            // idea 1: reorder the detections based on the st devs and pick first n
            let sorted = zip(stDevs, images).sorted { $0.0 > $1.0 }
            let sharpestImages = sorted.map { $0.1 }
    
            return Array(sharpestImages.prefix(howMany))
            
        case .sections:
            // idea 2: divide into n section and pick the sharpest image from each (more diverse data?)
            var selectedImages: [UIImage] = []

            for i in 0...howMany {
                var indexRange = i*(images.count/howMany)...(i+1)*(images.count/howMany)
                if indexRange.upperBound >= images.count {
                    indexRange = i*(images.count/howMany)...(images.count - 1)
                }
                
                let subStDevs = stDevs[indexRange]
                let subImages = images[indexRange]

                if let maxValue = subStDevs.max() {
                    let maxIndex = subStDevs.firstIndex(of: maxValue)!
                    selectedImages.append(subImages[maxIndex])
                }
            }

            return selectedImages
        }
    }
}

enum Method: String, CaseIterable, Identifiable {
    case evenlySpaced
    case highestStDev
    case sections

    var id: String { self.rawValue }
}
