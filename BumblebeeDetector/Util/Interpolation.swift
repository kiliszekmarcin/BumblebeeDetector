//
//  Interpolation.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 07/03/2021.
//

import Foundation
import AVFoundation
import UIKit

class Interpolation {
    let model: BumblebeeModel
    let asset: AVAsset
    let duration: Double
    let generator: AVAssetImageGenerator
    
    init(videoUrl url: URL) {
        do {
            self.model = try BumblebeeModel.init()
            
            // setup the asset and generator to extract images out of the video
            self.asset = AVAsset(url: url)
            self.duration = CMTimeGetSeconds(asset.duration)
            self.generator = AVAssetImageGenerator(asset: asset)
            
            self.generator.requestedTimeToleranceAfter = .zero
            self.generator.requestedTimeToleranceBefore = .zero
            self.generator.appliesPreferredTrackTransform = true
        } catch let error {
            fatalError("Could not initialise the model: " + error.localizedDescription)
        }
    }
    
    func detectByInterpolation(fps: Double, threshold: CGFloat) -> [UIImage] {
        // initialise arrays to store the data
        let times: [Double] = Array(stride(from: 0.0, to: duration, by: 1/fps))
        var coordinates: [CGRect?] = Array(repeating: nil, count: times.count)
        var detections: [UIImage] = []
        
        // interpolate at every half second range
        var frameCount = 0
        while frameCount < times.count {
            if frameCount + Int(fps/2) >= times.count {
                let interRange = frameCount...
                
                coordinates[interRange] = ArraySlice(interpolate(coordinates: Array(coordinates[interRange]),
                                                        times: Array(times[interRange]),
                                                        threshold: threshold))
                
                frameCount = times.count
            } else {
                let interRange = frameCount...frameCount + Int(fps/2)
                
                coordinates[interRange] = ArraySlice(interpolate(coordinates: Array(coordinates[interRange]),
                                                        times: Array(times[interRange]),
                                                        threshold: threshold))
                
                frameCount += Int(fps/2)
            }
        }
        
        // crop out images
        for i in 0..<times.count {
            do {
                // get image at time
                let cmTime = CMTimeMakeWithSeconds(Float64(times[i]), preferredTimescale: 600)
                let cgimg = try generator.copyCGImage(at: cmTime, actualTime: nil)
                
                // convert coordinates to be able to crop
                if let coords = coordinates[i] {
                    let beeRect = CGRect(x: CGFloat(cgimg.width) * (coords.origin.x - coords.width / 2),
                                         y: CGFloat(cgimg.height) * (coords.origin.y - coords.height / 2),
                                         width: CGFloat(cgimg.width) * coords.width,
                                         height: CGFloat(cgimg.height) * coords.height)
                    
                    let croppedImage = cgimg.cropping(to: beeRect)
                    
                    // scale the uiimage down
                    let uiimage = UIImage(cgImage: croppedImage!)
                    let imageSize = CGSize(width: beeRect.width, height: beeRect.height)
                    let renderer = UIGraphicsImageRenderer(size: imageSize)
                    let scaledImage = renderer.image { _ in
                        uiimage.draw(in: CGRect(origin: .zero, size: imageSize))
                    }
                    
                    detections.append(scaledImage)
                }
            } catch {
                print("Error when cropping detection", error.localizedDescription)
            }
        }
        
        return detections
    }
    
    func detectBeeAtTime(time: Double) -> CGRect? {
        do {
            let time = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: 600)
            let img = try generator.copyCGImage(at: time, actualTime: nil)
            
            // detect the bee
            return detectBeeOnImage(cgimage: img)
        } catch {
            print("Error when generating image from time:", error.localizedDescription)
        }
    
        return nil
    }
    
    func detectBeeOnImage(cgimage: CGImage) -> CGRect? {
        do {
            let modelInput = try BumblebeeModelInput.init(imageWith: cgimage, iouThreshold: nil, confidenceThreshold: nil)
            let prediction = try model.prediction(input: modelInput)
            let coordinates = prediction.coordinates //[0] - x centre of detection, [1] - y centre of detection, [2] - width, [3] - height
            
            if coordinates.count != 0 {
                return CGRect(x: coordinates[0].doubleValue,
                              y: coordinates[1].doubleValue,
                              width: coordinates[2].doubleValue,
                              height: coordinates[3].doubleValue)
            }
        } catch {
            print("Error when detecting bee: ", error.localizedDescription)
        }
        
        return nil
    }
    
    func interpolate(coordinates: [CGRect?], times: [Double], threshold: CGFloat) -> [CGRect?] {
        if coordinates.isEmpty {
            return []
        }
        
        // define indexes
        var firstIdx = 0
        var lastIdx = coordinates.count - 1
        
        // copy of the array we'll be working on
        var coords = coordinates
        
        var first: CGRect
        var last: CGRect

        // find first frame
        while coords[firstIdx] == nil {
            if let firstDetection = detectBeeAtTime(time: times[firstIdx]) {
                coords[firstIdx] = firstDetection
            } else {
                // no bee in first frame
                firstIdx += 1
                
                // return if invalid
                if firstIdx >= lastIdx {
                    return coords
                }
            }
        }
        first = coords[firstIdx]!
        
        // make sure there's more than one frame
        if firstIdx >= lastIdx {
            return coords
        }
        
        // find last frame
        while coords[lastIdx] == nil {
            if let lastDetection = detectBeeAtTime(time: times[lastIdx]) {
                coords[lastIdx] = lastDetection
                last = lastDetection
            } else {
                // no bee in last frame
                lastIdx -= 1
                
                // return if invalid
                if lastIdx <= firstIdx {
                    return coords
                }
            }
        }
        last = coords[lastIdx]!
        
        // make sure indexes arent broken
        if lastIdx <= firstIdx {
            return coords
        }
        
        // find middle frame
        var middleIdx = Int((firstIdx + lastIdx) / 2)
        var middle: CGRect
        
        // make sure middle exists
        if middleIdx == firstIdx || middleIdx == lastIdx {
            return coords
        }
        
        while coords[middleIdx] == nil {
            if let middleDetection = detectBeeAtTime(time: times[middleIdx]) {
                coords[middleIdx] = middleDetection
            } else {
                //no bee in the middle frame
                middleIdx -= 1
                
                // return if invalid
                if middleIdx <= firstIdx {
                    return coords
                }
            }
        }
        middle = coords[middleIdx]!
        
        
        // interpolation
        let xDistance = abs(middle.origin.x - (first.origin.x + last.origin.x)/2)
        let yDistance = abs(middle.origin.y - (first.origin.y + last.origin.y)/2)
        let biggerDistance = max(xDistance, yDistance)
        
        if biggerDistance > threshold {
            coords[firstIdx..<middleIdx] = ArraySlice(interpolate(coordinates: Array(coords[firstIdx..<middleIdx]), times: Array(times[firstIdx..<middleIdx]), threshold: threshold))
            
            coords[middleIdx+1...lastIdx] = ArraySlice(interpolate(coordinates: Array(coords[middleIdx+1...lastIdx]), times: Array(times[middleIdx+1...lastIdx]), threshold: threshold))
        } else {
            let numberOfSteps = CGFloat(lastIdx - firstIdx)
            let stepSizeX = (last.origin.x - first.origin.x) / numberOfSteps
            let stepSizeY = (last.origin.y - first.origin.y) / numberOfSteps
            let stepSizeW = (last.width - first.width) / numberOfSteps
            let stepSizeH = (last.height - first.height) / numberOfSteps
            
            for i in firstIdx+1..<lastIdx {
                coords[i] = CGRect(x: first.origin.x + stepSizeX,
                                   y: first.origin.y + stepSizeY,
                                   width: first.width + stepSizeW,
                                   height: first.height + stepSizeH)
            }
        }
        
        return coords
    }
}


/*
 input -> array of optional cgrects, output array of cgrects
 
 if first == nil {
    first = detect
 }
 if last == nil {
    last = detect
 }
 if middle == nil {
    middle = detect
 }
 
 if middle - (first + last) / 2  > threshold {
    array[first:middle] = interpolate
    array[middle:last] = interpolate
 } else {
    number_of_steps = input.size - 2
    step_size = (last - first) / number_of_steps
 
    for i in range(1, input.size) {
        array[i] = first + step_size * i
    }
 }
 
 
 
 */
