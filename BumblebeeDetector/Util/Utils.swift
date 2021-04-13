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
    /// date formatter - short date, short time
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// date formatter - short date, short time
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// get the first frame, location and date from the video (if present)
    static func getVideoMetadata(url: URL) -> (firstFrame: UIImage?, location: CLLocationCoordinate2D?, date: Date?) {
        var firstFrame: UIImage? = nil
        var location: CLLocationCoordinate2D? = nil
        var date: Date? = nil
        
        let asset = AVAsset(url: url)
        
        // get date
        date = asset.creationDate?.dateValue
        
        // get location
        let metadata = asset.commonMetadata
        let locationIdentifier = AVMetadataIdentifier.commonIdentifierLocation
        if let locationString = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: locationIdentifier).first?.stringValue {
            location = iso6709ToCLLocationCoordinate2D(locationString: locationString)
        }
        
        // get first frame
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            firstFrame = UIImage(cgImage: try generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 600), actualTime: nil))
        } catch let error {
            print("Error when extracting first frame after video selection")
            print(error.localizedDescription)
        }
        
        // return
        return (firstFrame, location, date)
    }
    
    /// convert iso6709 string to CLLocationCoordinate2D format
    static func iso6709ToCLLocationCoordinate2D(locationString: String) -> CLLocationCoordinate2D? {
        let indexLat = locationString.index(locationString.startIndex, offsetBy: 8)
        let indexLong = locationString.index(indexLat, offsetBy: 9)

        let lat = String(locationString[locationString.startIndex..<indexLat])
        let long = String(locationString[indexLat..<indexLong])

        if let lattitude = Double(lat), let longitude = Double(long) {
            return CLLocationCoordinate2D(latitude: lattitude, longitude: longitude)
        }
        
        return nil
    }
    
    /// convert coreML detection coordinates wrapped in CGRect to CGRect with a stanard coordinate system
    static func detectionCGRectToCropping(cgrect: CGRect, orgW: Double, orgH: Double) -> CGRect {
        detectionCGRectToCropping(
            detX: Double(cgrect.origin.x),
            detY: Double(cgrect.origin.y),
            detW: Double(cgrect.width),
            detH: Double(cgrect.height),
            orgW: orgW,
            orgH: orgH)
    }
    
    /// convert coreML detection coordinates to CGRect with a standard coordinate system
    static func detectionCGRectToCropping(detX: Double, detY: Double, detW: Double, detH: Double, orgW: Double, orgH: Double) -> CGRect {
        var xScale = orgW / orgH
        var yScale = orgH / orgW
        
        if xScale > yScale {
            yScale = 1
        } else {
            xScale = 1
        }
        
        let detectionRectangle = CGRect(x: orgW * (detX - (detW / xScale) / 2),
                                        y: orgH * (detY - (detH / yScale) / 2),
                                        width: orgW * detW / xScale,
                                        height: orgH * detH / yScale)
        
        let detectionSquare = Utils.squarify(rect: detectionRectangle, maxWidth: CGFloat(orgW), maxHeight: CGFloat(orgH))
        
        return detectionSquare
    }
    
    /// turn a CGRect into a square keeping the bee inside and possibly in the middle
    static func squarify(rect: CGRect, maxWidth: CGFloat, maxHeight: CGFloat) -> CGRect {
        // x, y are top left corned of the rect
        
        // try expanding the rectangle to a square, and then if it doens't fit in bounds, shift it so it does
        if rect.width > rect.height {
            // wider than taller -> need to add to height
            
            let difference = rect.width - rect.height
            
            var newY = rect.origin.y - difference/2
            var newHeight = rect.height + difference
            
            // if y got out of bounds try shifting to height if it can fit it too
            if newY < 0 {
                if newHeight + abs(newY) <= maxHeight {
                    newY = 0
                    newHeight += abs(newY)
                } else {
                    newY = 0
                    newHeight = maxHeight
                }
            }
            
            // if height got out of bounds try shifting it up
            if newHeight > maxHeight {
                if newY - (newHeight - maxHeight) >= 0 {
                    newY -= newHeight - maxHeight
                } else {
                    newY = 0
                    newHeight = maxHeight
                }
            }
            
            return CGRect(x: rect.origin.x, y: newY, width: rect.width, height: newHeight)
        } else if rect.height > rect.width {
            // taller than wide -> need to add to width
            
            let difference = rect.height - rect.width
            
            var newX = rect.origin.x - difference/2
            var newWidth = rect.width + difference
            
            // if y got out of bounds try shifting to height if it can fit it too
            if newX < 0 {
                if newWidth + abs(newX) <= maxWidth {
                    newX = 0
                    newWidth += abs(newX)
                } else {
                    newX = 0
                    newWidth = maxWidth
                }
            }
            
            // if height got out of bounds try shifting it up
            if newWidth > maxWidth {
                if newX - (newWidth - maxWidth) >= 0 {
                    newX -= newWidth - maxWidth
                } else {
                    newX = 0
                    newWidth = maxWidth
                }
            }
            
            return CGRect(x: newX, y: rect.origin.y, width: newWidth, height: rect.height)
        } else {
            // square already
            return rect
        }
    }
    
    static func anyJsonToPredictions(json: Any?) -> [Prediction] {
        var predictions: [Prediction] = []
        
        if let jsonDict = json as? [String: Any] {
            if let jsonDeeper = jsonDict["pred"] as? [Any] {
                for item in jsonDeeper {
                    if let item = item as? [Any] {
                        let species = item[0] as! String
                        let confidence = item[1] as! Double
                        
                        predictions.append(Prediction(species: species, confidence: confidence))
                    }
                }
            } else if let errorMessage = jsonDict["error"] {
                predictions.append(Prediction(species: errorMessage as! String, confidence: 1.0))
            } else {
                predictions.append(Prediction(species: "Error", confidence: 1.0))
            }
        }
        
        return predictions
    }
}
