//
//  ImageSimilarityView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 14/04/2021.
//

import SwiftUI

struct ImageSimilarityView: View {
    
    @State var image1: UIImage? = UIImage(named: "placeholderBee.png")!
    @State var image2: UIImage? = UIImage(named: "placeholderBee.png")!
    @State var distance: Float?
    @State private var isShowImagePicker = false
    @State private var imagePicked = 1
    
    var body: some View {
        VStack(spacing: 10) {
            Button(
                action: {
                    self.isShowImagePicker = true
                    self.imagePicked = 1
                },
                label: {
                Image(uiImage: image1!)
                    .resizable().scaledToFit()
                }
            )
            Text("First image")
            
            Button(
                action: {
                    self.isShowImagePicker = true
                    self.imagePicked = 2
                },
                label: {
                Image(uiImage: image2!)
                    .resizable().scaledToFit()
                }
            )
            Text("Second image")
            
            Button(
                action: {
                    calculateDistance()
                },
                label: {
                    Text("Distance:")
                        .font(.headline)
                    Text(distance == nil ? "not calculated" : String(format: "%.3f", distance!))
                }
            )
        }.padding()
        .sheet(isPresented: $isShowImagePicker) {
            ImagePicker(
                sourceType: .photoLibrary,
                selectedImage: imagePicked == 1 ? $image1 : $image2,
                selectedVideoUrl: Binding.constant(nil),
                mediaTypes: ["public.image"])
        }
    }
}

extension ImageSimilarityView {
    private func calculateDistance() {
        if let first = self.image1, let second = self.image2 {
            self.distance = ImageSimilarity.imageDistance(from: first, to: second)
        }
    }
}


struct ImageSimilarityView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSimilarityView(
            distance: 12.34
        )
    }
}
