//
//  AnimationView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 14/01/2021.
//

import SwiftUI
import UIKit

struct AnimationView: UIViewRepresentable {
    var imageSize: CGSize = CGSize(width: 100, height: 100)
    var animatedImage = UIImage.animatedImage(
        with: [UIImage(named: "placeholderBee")!, UIImage(named: "placeholderBeeInverted")!],
        duration: 0.5)
    
    func makeUIView(context: Self.Context) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        let animationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

        animationImageView.clipsToBounds = true
//        animationImageView.layer.cornerRadius = 5
        animationImageView.autoresizesSubviews = true
        animationImageView.contentMode = UIView.ContentMode.scaleAspectFit

        animationImageView.image = animatedImage

        containerView.addSubview(animationImageView)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimationView>) {

    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationView()
    }
}
