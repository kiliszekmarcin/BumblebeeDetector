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
    @State private var isShowActivity = false
    
    var body: some View {
        ZStack() {
            ScrollView {
                ProfilePictureAndBackground(
                    profilePicture: newBee.profileImage,
                    backgroundPicture: newBee.backgroundImage,
                    loading: self.isShowActivity
                ).frame(width: UIScreen.main.bounds.width)
                
                if !newBee.detections.isEmpty {
                    AnimationView(
                        imageSize: CGSize(width: 200, height: 200),
                        animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 30))
                    ).frame(width: 200, height: 200, alignment: .center)
                }
            }
            .navigationBarTitle("Track a new bee")
            
            VStack {
                Spacer()
                
                // buttons area TODO: camera roll / camera
                HStack(spacing: 10.0) {
                    FilledButton(
                        title: "Select a video",
                        disabled: self.isShowActivity || !self.newBee.detections.isEmpty
                    ) {
                        self.isShowPhotoLibrary = true
                    }
                    
                    FilledButton(
                        title: "Detect",
                        disabled: self.isShowActivity || !self.newBee.detections.isEmpty
                    ) {
                        detectPressed()
                    }
                }
                .padding()
                .shadow(radius: 7)
            }.sheet(isPresented: $isShowPhotoLibrary, onDismiss: { }) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
            }
        }
    }
}


extension AddBeeView {
    func detectPressed() {
        if let url = newBee.videoURL {
            self.isShowActivity = true
            
            DispatchQueue(label: "beeDetection").async {
                let localiser = BeeLocaliser()
                
                newBee.detections = localiser.detectBee(onVideo: url, fps: 16)
                
                if let firstImage = newBee.detections.first {
                    newBee.profileImage = firstImage
                }
                
                // get the background image
                newBee.backgroundImage = localiser.getFirstFrame()
                
                self.isShowActivity = false
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
