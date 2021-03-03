//
//  ProfilePictureAndBackground.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 18/02/2021.
//

import SwiftUI
import CoreLocation

struct ProfilePictureAndBackground: View {
    let profilePicture : UIImage
    let backgroundPicture : UIImage?
    let location : CLLocationCoordinate2D?
    
    let loading : Bool
    
    var body: some View {
        VStack {
            if let bgLocation = location {
                MapView(coordinate: bgLocation)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 275)
                    .cornerRadius(15)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 7)
            }
            
            // bee circle
            Image(uiImage: profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .blur(radius: loading ? 5.0 : 0)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
                .overlay(loading ? LoadingIndicator() : nil)
                .offset(y: backgroundPicture == nil ? 0 : -130)
                .padding()
                .padding(.bottom, backgroundPicture == nil ? 0 : -130)
        }
    }
}

struct ProfilePictureAndBackground_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderImg = UIImage(named: "placeholderBee.png")!
        let beeImage = UIImage(named: "frame1.png")!
        let beeBackground = UIImage(named: "background.png")!
        let britishMuseum = CLLocationCoordinate2D(latitude: 51.519581, longitude: -0.127002)
        
        Group {
            ProfilePictureAndBackground(
                profilePicture: beeImage,
                backgroundPicture: beeBackground,
                location: britishMuseum,
                loading: false
            )
            
            ProfilePictureAndBackground(
                profilePicture: beeImage,
                backgroundPicture: beeBackground,
                location: nil,
                loading: true
            )
            
            ProfilePictureAndBackground(
                profilePicture: placeholderImg,
                backgroundPicture: nil,
                location: nil,
                loading: false
            )
            
            ProfilePictureAndBackground(
                profilePicture: placeholderImg,
                backgroundPicture: nil,
                location: nil,
                loading: true
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
