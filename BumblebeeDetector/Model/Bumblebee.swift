//
//  Bumblebee.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import Foundation
import UIKit

struct Bumblebee {
    var date: Date
    var image: UIImage {
        // when setting the image, try to detect the bumblebee and crop it out
        didSet {
            do {
                let model = try BumblebeeModel.init()
                
                // try to create a buffer from the image, and then use the model to get a prediction
                if let bufferImage = buffer(from: image) {
                    let prediction = try model.prediction(image: bufferImage, iouThreshold: nil, confidenceThreshold: nil)
                    
                    let coordinates = prediction.coordinates
                    
                    // crop the bee out
                    let cropped = crop(image: image, x: coordinates[0].doubleValue, y: coordinates[1].doubleValue, width: coordinates[2].doubleValue, height: coordinates[3].doubleValue)
                    
                    detected = cropped
                }
            } catch let error {
                print("Error when detecting the bee on the image")
                print(error.localizedDescription)
            }
        }
    }
    
    var detected: UIImage?
}
