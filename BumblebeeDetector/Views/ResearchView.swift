//
//  ResearchView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 14/04/2021.
//

import SwiftUI

struct ResearchView: View {
    
    @Binding var researchToggle: Bool
    
    var body: some View {
        List {
            Toggle("Research mode", isOn: $researchToggle)
            NavigationLink("Edge detection", destination: EdgeDetectionView())
            NavigationLink("Image similarity", destination: ImageSimilarityView())
        }.navigationTitle("Research mode settings")
    }
}

struct ResearchView_Previews: PreviewProvider {
    static var previews: some View {
        ResearchView(researchToggle: Binding.constant(true))
    }
}
