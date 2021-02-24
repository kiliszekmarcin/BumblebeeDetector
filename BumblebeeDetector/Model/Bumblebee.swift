//
//  Bumblebee.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import Foundation
import UIKit

struct BumblebeeOld {
    var date: Date
    var profileImage: UIImage // bee's first detection
    var backgroundImage: UIImage? // first whole frame to display in the background
    
    var videoURL: URL?
    
    var detections: [UIImage] = []
}
