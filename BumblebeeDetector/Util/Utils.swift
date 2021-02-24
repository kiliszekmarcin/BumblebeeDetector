//
//  Utils.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 06/01/2021.
//

import Foundation
import UIKit
import AVFoundation

class Utils {
    static func getVideoFirstFrame(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        
        do {
            return UIImage(cgImage: try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 600), actualTime: nil))
        } catch let error {
            print("Error when extracting first frame after video selection")
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }

    static func imagesFromCoreData(object: Data?) -> [UIImage]? {
        var retVal = [UIImage]()

        guard let object = object else { return nil }
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
        
        return retVal
    }
}
