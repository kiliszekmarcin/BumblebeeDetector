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
}
