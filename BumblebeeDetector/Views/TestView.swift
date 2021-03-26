//
//  TestView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 26/03/2021.
//

import SwiftUI

struct TestView: View {
    @State private var pickedImage: UIImage?
    @State private var convolvedImage: UIImage?
    @State private var videoUrl: URL?
    @State private var isShowImagePicker = false
    
    var body: some View {
        VStack {
            Button("Pick image") {
                self.isShowImagePicker = true
            }
            
            if pickedImage != nil {
                Text("Picked")
                Image(uiImage: pickedImage!)
                    .resizable()
                    .scaledToFit()
            }
            
            if convolvedImage != nil {
                Text("Convolved")
                Image(uiImage: convolvedImage!)
                    .resizable()
                    .scaledToFit()
            }
        }.sheet(isPresented: $isShowImagePicker, onDismiss: { imagePicked() }) {
            ImagePicker(sourceType: UIImagePickerController.SourceType.photoLibrary, selectedImage: $pickedImage, selectedVideoUrl: $videoUrl)
        }
    }
}

extension TestView {
    func imagePicked() {
        print("picked")
        let quality = ImageQuality()
        
        if pickedImage != nil {
            convolvedImage = quality.imageSharpness(image: pickedImage!)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
