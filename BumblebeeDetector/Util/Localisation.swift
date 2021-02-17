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
    var firstFrame: UIImage?
    
    init() {
        do {
            model = try BumblebeeModel.init()
        } catch let error {
            fatalError("Could not initialise the model: " + error.localizedDescription)
        }
    }

    /// Detects a bee on CGImage, and returns a UIImage scaled down to fit the size of the detection
    func detectBee(onImage image: CGImage) -> UIImage? {
        do {
            let modelInput = try BumblebeeModelInput.init(imageWith: image, iouThreshold: nil, confidenceThreshold: nil)
            let prediction = try model.prediction(input: modelInput)
            let coordinates = prediction.coordinates
            
            if coordinates.count != 0 {
                let croppedImage = image.cropping(to: CGRect(x: Double(image.width) * (coordinates[0].doubleValue - coordinates[2].doubleValue / 2),
                                                             y: Double(image.height) * (coordinates[1].doubleValue - coordinates[3].doubleValue / 2),
                                                             width: coordinates[2].doubleValue * Double(image.width),
                                                             height: coordinates[3].doubleValue * Double(image.height)))
                
                // scale the uiimage down
                let uiimage = UIImage(cgImage: croppedImage!)
                let imageSize = CGSize(width: coordinates[2].doubleValue * Double(image.width), height: coordinates[3].doubleValue * Double(image.height))
                let renderer = UIGraphicsImageRenderer(size: imageSize)
                let scaledImage = renderer.image { _ in
                    uiimage.draw(in: CGRect(origin: .zero, size: imageSize))
                }
                
                return scaledImage
            }
        } catch let error {
            print("Error when predicting bumblebee location")
            print(error.localizedDescription)
        }
    
        return nil
    }
    
    /// Detects the bumblebee on the video. Requires a URL and fps, and returns an array of images.
    func detectBee(onVideo url: URL, fps: Int = 30) -> [UIImage] {
        var detections: [UIImage] = []
        
        let asset = AVAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        generator.appliesPreferredTrackTransform = true
        
        do {
            self.firstFrame = UIImage(cgImage: try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 600), actualTime: nil))
            
            for index in stride(from: 0.0, through: duration, by: 1.0/Double(fps)) {
                // get image from the generator
                let time = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
                let img = try generator.copyCGImage(at: time, actualTime: nil)
                
                // detect the bee
                autoreleasepool {
                    if let detection = detectBee(onImage: img) {
                        detections.append(detection)
                    }
                }
            }
        } catch let error {
            print("Error when detecting from video")
            print(error.localizedDescription)
        }
        
        return detections
    }
    
    func getFirstFrame() -> UIImage? {
        return self.firstFrame
    }
}


