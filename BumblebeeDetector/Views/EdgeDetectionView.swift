//
//  EdgeDetectionView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 14/04/2021.
//

import SwiftUI

struct EdgeDetectionView: View {
    
    @State var pickedImage: UIImage? = UIImage(named: "placeholderBee.png")
    @State var convolvedImage: UIImage? = UIImage(named: "placeholderConvolved.jpeg")
    @State var mean: Double?
    @State var stdev: Double?
    @State private var isShowImagePicker = false
    @State private var videoUrl: URL?
    
    var body: some View {
        VStack(spacing: 10) {
            Button(
                action: {
                    self.isShowImagePicker = true
                },
                label: {
                Image(uiImage: pickedImage!)
                    .resizable().scaledToFit()
                }
            )
            Text("Picked image")
            
            if convolvedImage != nil {
                Image(uiImage: convolvedImage!)
                    .resizable().scaledToFit()
                
                Text("Convolved image")
            }
            
            DetailRow(
                title: "Mean",
                caption: mean == nil ? "not calculated" : String(format: "%.3f", mean!)
            )
            DetailRow(
                title: "Standard deviation",
                caption: stdev == nil ? "not calculated" : String(format: "%.3f", stdev!)
            )
        }.padding()
        .sheet(isPresented: $isShowImagePicker, onDismiss: { imagePicked() }) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $pickedImage, selectedVideoUrl: $videoUrl)
        }
    }
}

extension EdgeDetectionView {
    private func imagePicked() {
        if pickedImage != nil {
            // image
            convolvePickedImage()
        } else if videoUrl != nil {
            // video
            let detector = BeeLocaliser()
            let detections = detector.detectBee(onVideo: videoUrl!, fps: 1)
            
            if let firstDetection = detections.first {
                pickedImage = firstDetection
                convolvePickedImage()
            }
        }
    }
    
    private func convolvePickedImage() {
        let qualityDetector = ImageQuality()
        (convolvedImage, stdev, mean) = qualityDetector.imageSharpness(image: pickedImage!)
    }
}

struct EdgeDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        EdgeDetectionView(
            pickedImage: UIImage(named: "placeholderBee.png"),
            convolvedImage: UIImage(named: "placeholderBee.png"),
            mean: 12.34,
            stdev: 43.21)
    }
}
