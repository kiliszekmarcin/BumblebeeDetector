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
                    } else {
                        detectedImage = nil
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
                // when video url is set, extract the frames.
                detections = []
                
                let asset = AVAsset(url: videoURL!)
                let duration = CMTimeGetSeconds(asset.duration)
                let generator = AVAssetImageGenerator(asset:asset)
                let model: BumblebeeModel

                generator.appliesPreferredTrackTransform = true
                
                do {
                    try model = BumblebeeModel.init()
                    
                    // set the original image to the first frame
                    image = UIImage(cgImage: try generator.copyCGImage(at: CMTime(value: 0, timescale: 600), actualTime: nil))
                    
                    //DEBUGGING
                    let start = DispatchTime.now()
                    var counter = 0
                    
                    // increments of 1/30 s
                    for index in stride(from: 0, to: duration, by: 1/30) {
                        counter += 1
                        
                        let time = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
                        let img = try generator.copyCGImage(at: time, actualTime: nil)
                        
                        // save the image (only the detection to preserve memory)
                        // try to create a buffer from the image, and then use the model to get a prediction
//                        let bufferImage = pixelBufferFromCGImage(image: img) TODO: FIND A WAY TO MAKE THIS WORK TO AVOID CONVERSION
                        let uiimg = UIImage(cgImage: img)
                        let bufferImage = buffer(from: uiimg)!
                        let prediction = try model.prediction(image: bufferImage, iouThreshold: nil, confidenceThreshold: nil)
                        
                        let coordinates = prediction.coordinates
                        
                        // check if there's any detection present
                        if coordinates.count != 0 {
                            // crop the bee out
                            let cropped = crop(image: uiimg, x: coordinates[0].doubleValue, y: coordinates[1].doubleValue, width: coordinates[2].doubleValue, height: coordinates[3].doubleValue)
                            
                            // add the detection to the array
                            detections.append(cropped)
                        }
                    }
                    
                    let end = DispatchTime.now()
                    
                    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                    let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests

                    print("Time to extract \(counter) frames from a \(duration)s long video and classify them (\(detections.count)) detections): \(timeInterval) seconds")
                } catch {
                    print("Error while processing the video")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    var detections: [UIImage] = []
}
