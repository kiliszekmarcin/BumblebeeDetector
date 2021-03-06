//
//  Requests.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 29/03/2021.
//  snippets adapted from https://www.donnywals.com/uploading-images-and-forms-to-a-server-using-urlsession/

import UIKit
import Alamofire

class Requests {
    static func sendImages(images: [UIImage], imagesToSend: Int = 5, method: Method = .evenlySpaced, completion: @escaping (_ json: Any?)->()) -> [UIImage] {
        let url = URL(string: "http://54.171.168.100/api/image")!
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
        if images.count <= howMany {
            return images
        }
        
        switch method {
        case .evenlySpaced:
            // baseline: evenly spaced items
            let step = Double(images.count)/Double(howMany)
            var indices = Array(0..<howMany) // generate range of how many elements
            indices = indices.map { Int(Double($0) * step) } // multiply range by step and cast to int
            let selectedImages = indices.map { images[$0] }

            return selectedImages
        case .highestStDev:
            // idea 1: reorder the detections based on the st devs and pick first n
            // calculate standard derivations of edges in the detections
            let stDevs = ImageQuality().sequenceSharpnessStDev(images: images)
            
            let sorted = zip(stDevs, images).sorted { $0.0 > $1.0 }
            let sharpestImages = sorted.map { $0.1 }
    
            return Array(sharpestImages.prefix(howMany))
            
        case .sectionedMaxStDev:
            // idea 2: divide into n section and pick the sharpest image from each (more diverse data?)
            var selectedImages: [UIImage] = []
            // calculate standard derivations of edges in the detections
            let stDevs = ImageQuality().sequenceSharpnessStDev(images: images)
            
            for i in 0..<howMany {
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
        
        case .belowAverage:
            // idea 3: go in a loop removing images with below average st dev and similarity distance
            var selectedImages: [UIImage] = images
            
            while selectedImages.count > howMany {
                // calculate standard derivations of edges in the detections
                let stDevs = ImageQuality().sequenceSharpnessStDev(images: selectedImages)
                
                // remove the below average half of st devs
                let avgStDev = stDevs.reduce(0.0) {
                    return $0 + $1/Double(stDevs.count)
                }
                
                var filtered = filterOrReturnMin(toFilter: zip(stDevs, selectedImages), value: avgStDev, min: howMany)
                selectedImages = filtered.map { $0.1 }
                
                if selectedImages.count <= howMany { return selectedImages }
                
                // calculate image similarities
                let similarities = ImageSimilarity.imageArrayDistances(array: selectedImages).map { Double($0) }
                let avgSimilarity = similarities.reduce(0.0) {
                    return $0 + $1/Double(similarities.count)
                }
                
                // remove the below average similarities
                filtered = filterOrReturnMin(toFilter: zip(similarities, selectedImages), value: Double(avgSimilarity), min: howMany)
                selectedImages = filtered.map { $0.1 }
            }
            
            return selectedImages
            
        case .mostDifferent:
            // idea 4: pick most different images by going in a loop, calculating differences to the next image and deleting bottom 25%
            var selectedImages = images
            
            while selectedImages.count > howMany {
                let similarities = ImageSimilarity.imageArrayDistances(array: selectedImages)
                
                // sort the similarities and get rid of bottom 25%
                var sorted = zip(similarities, selectedImages).sorted { $0.0 > $1.0 }
                let reduced = Int(Double(sorted.count)*0.75)
                if reduced >= howMany {
                    sorted = Array(sorted.prefix(reduced))
                } else {
                    sorted = Array(sorted.prefix(howMany))
                }
                
                selectedImages = sorted.map { $0.1 }
            }
            
            return selectedImages
            
        case .pairwiseStDevAndDifferent:
            // idea 5: go in pairs and get rid of the less sharp image in each pair.
            // then pick most different images using the MostDifferent method.
            var selectedImages: [UIImage] = []
            let stDevs = ImageQuality().sequenceSharpnessStDev(images: images)
            
            for index in stride(from: 0, to: stDevs.count, by: 2) {
                // if it's not the last element, compare st devs and keep the one with higher st dev.
                if index != stDevs.count-1 {
                    if stDevs[index] > stDevs[index+1] {
                        selectedImages.append(images[index])
                    } else {
                        selectedImages.append(images[index+1])
                    }
                }
            }
            
            // after removing the less sharp half of images, use the mostDifferent method.
            return selectionMethod(images: selectedImages, howMany: howMany, method: .mostDifferent)
        }
    }
    
    static private func filterOrReturnMin(toFilter: Zip2Sequence<[Double], [UIImage]>, value: Double, min: Int) -> [(Double, UIImage)] {
        // filter acording to the filter value
        let filtered = toFilter.filter { $0.0 > value }
        
        // if there's less filtered elements than the minimum, sort and return the minimum
        if filtered.count < min {
            let sorted = toFilter.sorted { $0.0 > $1.0 }
            return Array(sorted.prefix(min))
        }
        
        return filtered
    }
}

enum Method: String, CaseIterable, Identifiable {
    case evenlySpaced
    case highestStDev
    case sectionedMaxStDev
    case belowAverage
    case mostDifferent
    case pairwiseStDevAndDifferent

    var id: String { self.rawValue }
}
