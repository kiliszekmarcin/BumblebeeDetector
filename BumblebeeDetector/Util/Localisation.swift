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
    var profilePicture: UIImage?
    var detections: Int = 0
    
    init() {
        do {
            model = try BumblebeeModel.init()
        } catch let error {
            fatalError("Could not initialise the model: " + error.localizedDescription)
        }
    }

    /// crop out bee from the image using a rect. resize to 255x255 image (api input)
    private func cropOutBee(fromImage image: CGImage, to rect: CGRect) -> UIImage {
        let croppedImage = image.cropping(to: rect)
        
        // scale the uiimage down
        let uiimage = UIImage(cgImage: croppedImage!)
        let imageSize = CGSize(width: 255, height: 255)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let scaledImage = renderer.image { _ in
            uiimage.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        
        return scaledImage
    }
    
    /// Detects a bee on CGImage, and returns a cgrect scaled down to fit the size of the detection
    private func detectBeeRect(onImage image: CGImage) -> CGRect? {
        detections += 1
        
        do {
            let modelInput = try BumblebeeModelInput.init(imageWith: image, iouThreshold: nil, confidenceThreshold: nil)
            let prediction = try model.prediction(input: modelInput)
            let coordinates = prediction.coordinates //[0] - x centre of detection, [1] - y centre of detection, [2] - width, [3] - height
            
            let threshold = 0.8
            if prediction.confidence.count >= 1 {
                if let doubleConf = prediction.confidence[0] as? Double {
                    if doubleConf > threshold && coordinates.count != 0 {
                        let beeRect = Utils.detectionCGRectToCropping(
                            detX: coordinates[0].doubleValue,
                            detY: coordinates[1].doubleValue,
                            detW: coordinates[2].doubleValue,
                            detH: coordinates[3].doubleValue,
                            orgW: Double(image.width),
                            orgH: Double(image.height))
                        
                        return beeRect
                    }
                }
            }
        } catch let error {
            print("Error when predicting bumblebee location")
            print(error.localizedDescription)
        }
    
        return nil
    }
    
    /// detect bee on an image and return a cropped image
    func detectBeeImg(onImage image: CGImage) -> UIImage? {
        if let detectionRect = detectBeeRect(onImage: image) {
            return cropOutBee(fromImage: image, to: detectionRect)
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
            self.profilePicture = try getFirstFrameProfilePic(generator: generator)
            
            for index in stride(from: 0.0, through: duration, by: 1.0/Double(fps)) {
                // get image from the generator
                let time = CMTimeMakeWithSeconds(Float64(index), preferredTimescale: 600)
                let img = try generator.copyCGImage(at: time, actualTime: nil)
                
                // detect the bee
                autoreleasepool {
                    if let detectionImg = detectBeeImg(onImage: img) {
                        detections.append(detectionImg)
                    }
                }
            }
        } catch let error {
            print("Error when detecting from video")
            print(error.localizedDescription)
        }
        
        return detections
    }
    
    private func getFirstFrameProfilePic(generator: AVAssetImageGenerator) throws -> UIImage? {
        // get a slightly zoomed out profile pic
        let firstFrame = try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 600), actualTime: nil)
        if let detection = detectBeeRect(onImage: firstFrame) {
            // zoom out by 10%
            let scale:CGFloat = 0.50
            var zoomedOut = detection.insetBy(dx: -detection.width * scale/2, dy: -detection.height * scale/2)
            
            // make sure it doesn't have negative values
            if zoomedOut.origin.x < 0 {
                zoomedOut = CGRect(x: 0, y: zoomedOut.origin.y, width: zoomedOut.width, height: zoomedOut.height)
            }
            if zoomedOut.origin.y < 0 {
                zoomedOut = CGRect(x: zoomedOut.origin.x, y: 0, width: zoomedOut.width, height: zoomedOut.height)
            }
            
            // make sure width and height aren't larger than the image
            if zoomedOut.width > CGFloat(firstFrame.width) {
                zoomedOut = CGRect(x: zoomedOut.origin.x, y: zoomedOut.origin.y, width: CGFloat(firstFrame.width), height: zoomedOut.height)
            }
            if zoomedOut.height > CGFloat(firstFrame.height) {
                zoomedOut = CGRect(x: zoomedOut.origin.x, y: zoomedOut.origin.y, width: zoomedOut.width, height: CGFloat(firstFrame.height))
            }
            
            let squareZoomedOut = Utils.squarify(rect: zoomedOut, maxWidth: CGFloat(firstFrame.width), maxHeight: CGFloat(firstFrame.height))
            
            let croppedImg = cropOutBee(fromImage: firstFrame, to: squareZoomedOut)
            return croppedImg
        }
        
        return nil
    }
}


