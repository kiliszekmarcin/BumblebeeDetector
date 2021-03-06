//
//  ImageSimilarity.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 06/03/2021.
//

import Foundation
import Vision
import UIKit

class ImageSimilarity {
    
    static func imageArrayDistances(array: [UIImage]) -> [Float] {
        var distances: [Float] = []
        
        // generate feature prints for each image
        var fpos: [VNFeaturePrintObservation] = []
        for image in array {
            if let fpo = featurePrintObservationForImage(image: image){
                fpos.append(fpo)
            }
        }
        
        // calculate distance between following images
        for i in 0..<fpos.count-1 {
            if let distance = fpoDistance(from: fpos[i], to: fpos[i+1]) {
                distances.append(distance)
            }
        }
        // calculate distance between last and first image
        if let firstFpo = fpos.first, let lastFpo = fpos.last, let distance = fpoDistance(from: lastFpo, to: firstFpo) {
            distances.append(distance)
        }
        
        return distances
    }
    
    static func imageDistance(from: UIImage, to: UIImage) -> Float? {
        if let fromFPO = featurePrintObservationForImage(image: from), let toFPO = featurePrintObservationForImage(image: to) {
            return fpoDistance(from: fromFPO, to: toFPO)
        }
        
        return nil
    }
    
    static func fpoDistance(from: VNFeaturePrintObservation, to: VNFeaturePrintObservation) -> Float? {
        do {
            var distance = Float(0)
            try from.computeDistance(&distance, to: to)
            return distance
        } catch {
            print("Error computing distance between featureprints")
        }
        
        return nil
    }
    
    static func featurePrintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}
