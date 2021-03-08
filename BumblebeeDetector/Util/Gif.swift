//
//  Gif.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 08/03/2021.
//  source : https://gist.github.com/NikhilManapure/6f4c4e18692d51d6a8acfdc440dcac5f

import Foundation
import UIKit
import ImageIO
import MobileCoreServices

extension UIImage {
    static func animatedGif(from images: [UIImage]) -> URL? {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 1.0/16.0]] as CFDictionary
        
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("animated.gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    if let cgImage = image.cgImage {
                        CGImageDestinationAddImage(destination, cgImage, frameProperties)
                    }
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                print("Url = \(fileURL)")
                return fileURL
            }
        }
        
        return nil
    }
}
