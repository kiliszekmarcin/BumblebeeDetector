//
//  Prediction.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import Foundation

struct Prediction: Identifiable, Hashable {
    var id = UUID().uuidString

    var species: String
    var confidence: Double
}
