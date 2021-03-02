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
    var date: Date?
    var profileImage: UIImage? // bee's first detection
    var backgroundImage: UIImage? // first whole frame to display in the background
    var location: CLLocation?
    
    var videoURL: URL?
    
    var detections: [UIImage] = []
}

extension BumblebeeEdit {
    init(bumblebee: Bumblebee) {
        self.date = bumblebee.date
        self.profileImage = bumblebee.profileImage
        self.backgroundImage = bumblebee.backgroundImage
        self.videoURL = bumblebee.videoURL
        self.detections = bumblebee.detections
        self.location = bumblebee.location
    }
}
