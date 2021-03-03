//
//  PhotoSelectActionSheet.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 03/03/2021.
//

import SwiftUI

struct PhotoSelectActionSheet: ViewModifier {
    @Binding var presented: Bool
    
    @Binding var imagePickerMediaType: UIImagePickerController.SourceType
    @Binding var isShowImagePicker: Bool
    
    func body(content: Content) -> some View {
        return content
            .actionSheet(isPresented: $presented) {
                ActionSheet(
                    title: Text("Select image source"),
                    message: nil,
                    buttons: [
                        ActionSheet.Button.default(Text("Photo Library"), action: {
                            self.imagePickerMediaType = UIImagePickerController.SourceType.photoLibrary
                            self.isShowImagePicker = true
                        }),
                        ActionSheet.Button.default(Text("Camera"), action: {
                            self.imagePickerMediaType = UIImagePickerController.SourceType.camera
                            self.isShowImagePicker = true
                        }),
                        ActionSheet.Button.cancel()
                    ])
            }
    }
}
