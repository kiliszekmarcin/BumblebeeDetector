//
//  AddBeeView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import SwiftUI

struct AddBeeView: View {
    @State var newBee = Bumblebee(
        date: Date(),
        profileImage: UIImage(named: "placeholderBee.png")!
//        ,uiImgFrames: [UIImage(named: "placeholderBee.png")!, UIImage(named: "placeholderBeeInverted.png")!]
    )

    @State private var isShowPhotoLibrary = false
    
    var body: some View {
        ZStack() {
            ScrollView {
                VStack {
                    // top background (could be a map later?)
                    if newBee.backgroundImage != nil {
                        Image(uiImage: newBee.backgroundImage!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                    }
                    
                    // bee circle
                    Image(uiImage: newBee.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 7)
                        .offset(y: newBee.backgroundImage == nil ? 0 : -130)
                        .padding(.bottom, newBee.backgroundImage == nil ? 0 : -130)
                    
                    if !newBee.detections.isEmpty {
                        AnimationView(
                            imageSize: CGSize(width: 200, height: 200),
                            animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 30))
                        ).frame(width: 200, height: 200, alignment: .center)
                    }
                }.frame(width: UIScreen.main.bounds.width)
            }
            .navigationBarTitle("Track a new bee")
            
            VStack {
                Spacer()
                
                // buttons area TODO: camera roll / camera
                HStack(spacing: 10.0) {
                    Button("Select a video") {
                        self.isShowPhotoLibrary = true
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBlue))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    
                    Button("Detect") {
                        if let url = newBee.videoURL {
                            let localiser = BeeLocaliser()
                            
                            newBee.detections = localiser.detectBee(onVideo: url, fps: 16)
                            
                            if let firstImage = newBee.detections.first {
                                newBee.profileImage = firstImage
                            }
                            
                            // get the background image
                            newBee.backgroundImage = localiser.getFirstFrame()
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBlue))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                }
                .padding()
                .shadow(radius: 7)
            }.sheet(isPresented: $isShowPhotoLibrary, onDismiss: { }) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
            }
        }
    }
}

struct AddBeeView_Previews: PreviewProvider {
    static let placeholderBee = Bumblebee(
        date: Date(),
        profileImage: UIImage(named: "placeholderBee.png")!
    )
    static let exampleBee = Bumblebee(
        date: Date(),
        profileImage: UIImage(named: "frame1.png")!,
        backgroundImage: UIImage(named: "background.png"),
        detections: [
            UIImage(named: "frame1.png")!,
            UIImage(named: "frame2.png")!,
            UIImage(named: "frame3.png")!,
            UIImage(named: "frame4.png")!,
            UIImage(named: "frame5.png")!
        ]
    )
    
    static var previews: some View {
        Group {
            AddBeeView(newBee: placeholderBee)
                .previewDisplayName("Placeholder")
            AddBeeView(newBee: exampleBee)
                .previewDisplayName("Example bee")
        }
    }
}
