//
//  Utils.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 06/01/2021.
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation

class Utils {
    static let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static func getVideoMetadata(url: URL) -> (firstFrame: UIImage?, location: CLLocation?, date: Date?) {
        var firstFrame: UIImage? = nil
        var location: CLLocation? = nil
        var date: Date? = nil
        
        let asset = AVAsset(url: url)
        
        // get date
        date = asset.creationDate?.dateValue
        
        // get location
        let metadata = asset.commonMetadata
        let locationIdentifier = AVMetadataIdentifier.commonIdentifierLocation
        if let locationString = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: locationIdentifier).first?.stringValue {
            location = iso6709ToCLLocation(locationString: locationString)
        }
        
        // get first frame
        let generator = AVAssetImageGenerator(asset: asset)
        
        do {
            firstFrame = UIImage(cgImage: try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 600), actualTime: nil))
        } catch let error {
            print("Error when extracting first frame after video selection")
            print(error.localizedDescription)
        }
        
        // return
        return (firstFrame, location, date)
    }
    
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
    
    static func iso6709ToCLLocation(locationString: String) -> CLLocation? {
        let indexLat = locationString.index(locationString.startIndex, offsetBy: 8)
        let indexLong = locationString.index(indexLat, offsetBy: 9)

        let lat = String(locationString[locationString.startIndex..<indexLat])
        let long = String(locationString[indexLat..<indexLong])

        if let lattitude = Double(lat), let longitude = Double(long) {
            return CLLocation(latitude: lattitude, longitude: longitude)
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
