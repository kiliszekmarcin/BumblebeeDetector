//
//  AddBeeView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import SwiftUI
import CoreData

struct AddBeeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode
    
    @State var newBee = BumblebeeEdit()

    @State private var isShowImagePicker = false
    @State private var imagePickerMediaType = UIImagePickerController.SourceType.photoLibrary
    @State private var isShowActionSheet = false
    @State private var isShowActivity = false
    
    @State var editedBee: Bumblebee?
    
    var body: some View {
        ZStack() {
            ScrollView {
                ProfilePictureAndBackground(
                    profilePicture: newBee.profileImage ?? UIImage(named: "placeholderBee.png")!,
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
                        self.isShowActionSheet = true
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
            }.sheet(isPresented: $isShowImagePicker, onDismiss: { videoPicked() }) {
                ImagePicker(sourceType: imagePickerMediaType, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
            }
        }.actionSheet(isPresented: $isShowActionSheet, content: {
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
        })
        .toolbar {
            Button("Save") {
                if let editedB = editedBee {
                    // editing
                    editedB.date = newBee.date
                    editedB.videoURL = newBee.videoURL
                    editedB.backgroundImage = newBee.backgroundImage
                    editedB.profileImage = newBee.profileImage
                    editedB.detections = newBee.detections
                } else {
                    // creating a new bee
                    let newBumblebee = Bumblebee(context: viewContext)
                    newBumblebee.id = UUID()
                    newBumblebee.date = Date()
                    newBumblebee.videoURL = newBee.videoURL
                    newBumblebee.backgroundImage = newBee.backgroundImage
                    newBumblebee.profileImage = newBee.profileImage
                    newBumblebee.detections = newBee.detections
                }
                
                do {
                    try viewContext.save()
                    print("Bumblebee saved")
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Error while saving the bumblebee")
                    print(error.localizedDescription)
                }
            }.disabled(self.newBee.videoURL == nil || self.isShowActivity)
        }
    }
}


extension AddBeeView {
    func videoPicked() {
        if let url = newBee.videoURL {
            newBee.backgroundImage = Utils.getVideoFirstFrame(url: url)
        }
    }
    
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
    static let placeholderBee = BumblebeeEdit(
        date: Date(),
        profileImage: UIImage(named: "placeholderBee.png")!
    )
    static let exampleBee = BumblebeeEdit(
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
            NavigationView {
                AddBeeView(newBee: exampleBee)
            }.previewDisplayName("Example bee")
            
            NavigationView {
                AddBeeView(newBee: placeholderBee)
            }.previewDisplayName("Placeholder")
        }
    }
}
