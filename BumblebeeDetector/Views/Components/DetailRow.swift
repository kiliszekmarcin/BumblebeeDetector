//
//  DetailRow.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 17/03/2021.
//

import SwiftUI

struct DetailRow: View {
    let title: String
    let caption: String
    
    var body: some View {
        HStack {
            Text("\(title):")
                .font(.headline)
            
            Text(caption)
            
            Spacer()
        }
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(title: "Hello", caption: "world")
            .previewLayout(.sizeThatFits)
    }
}
