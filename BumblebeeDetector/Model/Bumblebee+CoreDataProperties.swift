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
    @NSManaged public var date: Date
    @NSManaged public var profileImageData: Data
    @NSManaged public var backgroundImageData: Data?
    @NSManaged public var videoURL: URL?
    @NSManaged public var detectionsData: Data?
    
    var profileImage: UIImage {
        set {
            profileImageData = newValue.pngData()!
        }
        get {
            UIImage(data: profileImageData)!
        }
    }
    
    var backgroundImage: UIImage? {
        set {
            if let imageData = newValue {
                backgroundImageData = imageData.pngData()
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
}

extension Bumblebee : Identifiable {

}
