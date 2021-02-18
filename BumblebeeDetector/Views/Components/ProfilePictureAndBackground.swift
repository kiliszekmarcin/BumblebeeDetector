//
//  ProfilePictureAndBackground.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 18/02/2021.
//

import SwiftUI

struct ProfilePictureAndBackground: View {
    let profilePicture : UIImage
    let backgroundPicture : UIImage?
    
    let loading : Bool
    
    var body: some View {
        VStack {
            // top background (could be a map later?)
            if backgroundPicture != nil {
                Image(uiImage: backgroundPicture!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 300)
            }
            
            // bee circle
            Image(uiImage: profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .blur(radius: loading ? 5.0 : 0)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
                .overlay(loading ? LoadingIndicator() : nil)
                .offset(y: backgroundPicture == nil ? 0 : -130)
                .padding(.bottom, backgroundPicture == nil ? 0 : -130)
        }
    }
}

struct ProfilePictureAndBackground_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderImg = UIImage(named: "placeholderBee.png")!
        let beeImage = UIImage(named: "frame1.png")!
        let beeBackground = UIImage(named: "background.png")!
        
        Group {
            ProfilePictureAndBackground(
                profilePicture: beeImage,
                backgroundPicture: beeBackground,
                loading: false
            )
            
            ProfilePictureAndBackground(
                profilePicture: beeImage,
                backgroundPicture: beeBackground,
                loading: true
            )
            
            ProfilePictureAndBackground(
                profilePicture: placeholderImg,
                backgroundPicture: nil,
                loading: false
            )
            
            ProfilePictureAndBackground(
                profilePicture: placeholderImg,
                backgroundPicture: nil,
                loading: true
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
