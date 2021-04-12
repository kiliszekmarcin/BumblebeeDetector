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
    @NSManaged public var predictedSpecies: [String]
    @NSManaged public var predictedConfidences: [Double]
    
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
            let dataArray = NSMutableArray()
            
            for img in newValue {
                if let data = img.pngData() {
                    dataArray.add(data)
                }
            }
            
            detectionsData = try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
        }
        get {
            if let imageData = detectionsData {
                var imageArray = [UIImage]()
                
                if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: imageData) {
                    for data in dataArray {
                        if let data = data as? Data, let image = UIImage(data: data) {
                            imageArray.append(image)
                        }
                    }
                }
                
                return imageArray
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
    
    var predictions: [Prediction] {
        set {
            predictedSpecies = []
            predictedConfidences = []

            for prediction in newValue {
                predictedSpecies.append(prediction.species)
                predictedConfidences.append(prediction.confidence)
            }
        }
        get {
            var newPredictions: [Prediction] = []

            for (species, confidence) in zip(predictedSpecies, predictedConfidences) {
                newPredictions.append(Prediction(species: species, confidence: confidence))
            }

            return newPredictions
        }
    }
}

extension Bumblebee : Identifiable {

}
