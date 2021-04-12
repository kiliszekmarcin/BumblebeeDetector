//
//  Bumblebee.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import Foundation
import UIKit
import CoreLocation

struct BumblebeeEdit {
    var name: String = ""
    var date: Date?
    var profileImage: UIImage? // bee's first detection
    var backgroundImage: UIImage? // first whole frame to display in the background
    var location: CLLocationCoordinate2D?
    
    var videoURL: URL?
    
    var detections: [UIImage] = []
    var predictions: [Prediction] = []
}

extension BumblebeeEdit {
    init(bumblebee: Bumblebee) {
        self.name = bumblebee.name
        self.date = bumblebee.date
        self.profileImage = bumblebee.profileImage
        self.backgroundImage = bumblebee.backgroundImage
        self.videoURL = bumblebee.videoURL
        self.detections = bumblebee.detections
        self.location = bumblebee.location
        self.predictions = bumblebee.predictions
    }
}
