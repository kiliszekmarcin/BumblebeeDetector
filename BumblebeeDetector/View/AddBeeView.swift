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
