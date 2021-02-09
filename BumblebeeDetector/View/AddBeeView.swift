//
//  AddBeeView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import SwiftUI

struct AddBeeView: View {
    @State private var newBee = Bumblebee(
        date: Date(),
        image: UIImage(named: "placeholderBee.png")!
//        ,uiImgFrames: [UIImage(named: "placeholderBee.png")!, UIImage(named: "placeholderBeeInverted.png")!]
    )

    @State private var isShowPhotoLibrary = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Original image")
                    .font(.headline)
                Button(action: {
                    self.isShowPhotoLibrary = true
                }) {
                    Image(uiImage: newBee.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                if newBee.detectedImage != nil || !newBee.detections.isEmpty {
                    Text("Deteced bee")
                        .font(.headline)
                }
                
                if newBee.detectedImage != nil && newBee.detections.isEmpty {
                    Image(uiImage: newBee.detectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                if !newBee.detections.isEmpty {
                    AnimationView(
                        imageSize: CGSize(width: 200, height: 200),
                        animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 30))
                    ).frame(width: 200, height: 200, alignment: .center)
                    
                    Text(String(newBee.detections.count) + " images")
                }
                
                Text("Date:")
                Text(newBee.date.description(with: nil))
                
                Spacer()
            }
        }
        .navigationBarTitle("Track a new bee")
        .sheet(isPresented: $isShowPhotoLibrary, onDismiss: {
            print("dismissed")
        }) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newBee.image, selectedVideoUrl: self.$newBee.videoURL)
        }
    }
}

struct AddBeeView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeeView()
    }
}
