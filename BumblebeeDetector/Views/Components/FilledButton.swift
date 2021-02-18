//
//  FilledButton.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 18/02/2021.
//

import SwiftUI

struct FilledButton: View {
    let title: String
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(disabled ? Color(UIColor.systemGray) : Color(UIColor.systemBlue)
            )
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .disabled(disabled)
    }
}

struct FilledButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilledButton(
                title: "Hello",
                disabled: false
            ) {
                print("works as a trailing thing")
            }
            FilledButton(
                title: "Hello",
                disabled: true,
                action: {}
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
