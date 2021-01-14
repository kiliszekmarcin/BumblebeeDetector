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
                Button(action: {
                    self.isShowPhotoLibrary = true
                }) {
                    Image(uiImage: newBee.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                if newBee.detectedImage != nil {
                    Image(uiImage: newBee.detectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                }
                
                if !newBee.uiImgFrames.isEmpty {
                    AnimationView(
                        imageSize: CGSize(width: 200, height: 200),
                        animatedImage: UIImage.animatedImage(with: newBee.uiImgFrames, duration: TimeInterval(newBee.uiImgFrames.count / 30))
                    ).frame(width: 200, height: 200, alignment: .center)
                    
                    Text(String(newBee.uiImgFrames.count) + " images")
                }
                
                Text("Date:")
                Text(newBee.date.description(with: nil))
                
                Spacer()
            }
        }
        .navigationBarTitle("Track a new bee")
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newBee.image, selectedVideoUrl: self.$newBee.videoURL)
        }
    }
}

struct AddBeeView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeeView()
    }
}
