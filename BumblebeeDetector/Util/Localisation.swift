//
//  Localisation.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 09/02/2021.
//

import Foundation
import UIKit
import AVFoundation

class BeeLocaliser {
    let model: BumblebeeModel
    
    init() {
        do {
            model = try BumblebeeModel.init()
        } catch let error {
            fatalError("Could not initialise the model: " + error.localizedDescription)
        }
    }
    
    func detectBee(onImage image: UIImage) -> UIImage? {
        if let cgimage = image.cgImage {
            do {
                let modelInput = try BumblebeeModelInput.init(imageWith: cgimage, iouThreshold: nil, confidenceThreshold: nil)
                let prediction = try model.prediction(input: modelInput)
                let coordinates = prediction.coordinates
                
                if coordinates.count != 0 {
                    return crop(image: image,
                                x: coordinates[0].doubleValue,
                                y: coordinates[1].doubleValue,
                                width: coordinates[2].doubleValue,
                                height: coordinates[3].doubleValue)
                }
            } catch let error {
                print("Error when predicting bumblebee location")
                print(error.localizedDescription)
            }
            
        } else {
            print("Failed to convert UIImage to CIImage")
        }
        
        return nil
    }
    
    func detectBee(onVideo url: URL) -> [UIImage] {
        var detections: [UIImage] = []
        
        let asset = AVAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true //????
        
        do {
            for index in stride(from: 0, through: duration, by: 1/30) {
                let time = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
                let img = try generator.copyCGImage(at: time, actualTime: nil)
                
                if let detection = detectBee(onImage: UIImage(cgImage: img)) {
                    detections.append(detection)
                }
            }
        } catch let error {
            print("Error when detecting from video")
            print(error.localizedDescription)
        }
        
        return detections
    }
}


