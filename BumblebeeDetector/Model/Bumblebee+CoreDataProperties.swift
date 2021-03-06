//
//  Bumblebee+CoreDataProperties.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 24/02/2021.
//
//

import Foundation
import CoreData
import UIKit


extension Bumblebee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bumblebee> {
        return NSFetchRequest<Bumblebee>(entityName: "Bumblebee")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var date: Date?
    @NSManaged public var profileImageData: Data?
    @NSManaged public var backgroundImageData: Data?
    @NSManaged public var videoURL: URL?
    @NSManaged public var detectionsData: Data?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    
    var profileImage: UIImage? {
        set {
            if let image = newValue {
                profileImageData = image.pngData()
            }
        }
        get {
            if let imageData = profileImageData {
                return UIImage(data: imageData)
            }
            return nil
        }
    }
    
    var backgroundImage: UIImage? {
        set {
            if let image = newValue {
                backgroundImageData = image.pngData()
            }
        }
        get {
            if let imageData = backgroundImageData {
                return UIImage(data: imageData)
            }
            
            return nil
        }
    }
    
    var detections: [UIImage] {
        set {
            detectionsData = Utils.coreDataObjectFromImages(images: newValue)
        }
        get {
            if let imageData = detectionsData {
                return Utils.imagesFromCoreData(object: imageData) ?? []
            }
            
            return []
        }
    }
    
    var location: CLLocationCoordinate2D? {
        set {
            if let newLocation = newValue {
                latitude = NSNumber(value: newLocation.latitude)
                longitude = NSNumber(value: newLocation.longitude)
            } else {
                latitude = nil
                longitude = nil
            }
        }
        get {
            if let lat = latitude, let lon = longitude {
                return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
            }
            
            return nil
        }
    }
}

extension Bumblebee : Identifiable {

}
