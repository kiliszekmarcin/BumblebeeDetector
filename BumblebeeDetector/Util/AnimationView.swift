//
//  AnimationView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 14/01/2021.
//

import SwiftUI
import UIKit

struct AnimationView: UIViewRepresentable {
    var animatedImage = UIImage.animatedImage(
        with: [UIImage(named: "placeholderBee")!, UIImage(named: "placeholderBeeInverted")!],
        duration: 0.5)
    
    func makeUIView(context: Self.Context) -> UIView {
//        let contentView = UIImageView()
//        let animationView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500))
//
//        animationView.clipsToBounds = true
//        animationView.autoresizesSubviews = true
//        animationView.contentMode = UIViewType.ContentMode.scaleAspectFit
//        animationView.image = animatedImage
//
//        contentView.autoresizesSubviews = true
//        contentView.addSubview(animationView)
//
//
//        return contentView
        
        let animationView = UIImageView()

        animationView.clipsToBounds = true
        animationView.autoresizesSubviews = true
        animationView.contentMode = UIViewType.ContentMode.scaleAspectFit
        animationView.image = animatedImage
        
        return animationView
        
//        let someView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
//        let someImage = UIImageView(frame: CGRect(x: 20, y: 100, width: 360, height: 180))
//        someImage.clipsToBounds = true
//        someImage.layer.cornerRadius = 20
//        someImage.autoresizesSubviews = true
//        someImage.contentMode = UIView.ContentMode.scaleAspectFit
//        someImage.image = animatedImage
//        someView.addSubview(someImage)
//        return someView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimationView>) {

    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationView()
    }
}
