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
    var image: UIImage
    
    var detectedImage: UIImage?
    
    var videoURL: URL? {
        didSet {
            let localiser = BeeLocaliser()
            
            detections = localiser.detectBee(onVideo: videoURL!)
            
            print(detections.count)
        }
    }
    
    var detections: [UIImage] = []
}
