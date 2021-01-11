//
//  Bumblebee.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import Foundation
import UIKit
import AVFoundation

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
                    
                    // check if there's any detection present
                    if coordinates.count != 0 {
                        // crop the bee out
                        let cropped = crop(image: image, x: coordinates[0].doubleValue, y: coordinates[1].doubleValue, width: coordinates[2].doubleValue, height: coordinates[3].doubleValue)
                        
                        detectedImage = cropped
                    }
                }
            } catch let error {
                print("Error when detecting the bee on the image")
                print(error.localizedDescription)
            }
        }
    }
    
    var detectedImage: UIImage?
    
    var videoURL: URL? {
        didSet {
            do {
                frames = []
                
                let asset = AVAsset(url: videoURL!)
                let duration = CMTimeGetSeconds(asset.duration)
                let generator = AVAssetImageGenerator(asset:asset)
                
                generator.appliesPreferredTrackTransform = true
                
                for index in 0 ..< Int(duration) {
                    let time = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
                    let img:CGImage
                    do {
                        try img = generator.copyCGImage(at: time, actualTime: nil)
                    } catch {
                        return
                    }
                    
                    frames.append(img)
                }
                
                if !frames.isEmpty {
                    image = UIImage(cgImage: frames.first!)
                }
            }
        }
    }
    
    var frames: [CGImage] = []
}
