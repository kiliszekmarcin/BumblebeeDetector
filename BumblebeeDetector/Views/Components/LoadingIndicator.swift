//
//  LoadingIndicator.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 18/02/2021.
//

import SwiftUI

struct LoadingIndicator: View {
    var loadingText: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 100, height: 75)
                .opacity(0.5)
                .cornerRadius(15)
            
            ProgressView(loadingText)
                .brightness(1)
        }
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator(loadingText: "Loading")
            .previewLayout(.sizeThatFits)
    }
}
