//
//  Bumblebee.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import Foundation
import UIKit

struct Bumblebee {
    var date: Date
    var profileImage: UIImage // bee's first detection
    var firstFrame: UIImage? // first whole frame to display in the background
    
    var videoURL: URL? {
        didSet {
            let localiser = BeeLocaliser()
            
            detections = localiser.detectBee(onVideo: videoURL!, fps: 16)
            
            if let firstImage = detections.first {
                profileImage = firstImage
            }
        }
    }
    
    var detections: [UIImage] = []
}
