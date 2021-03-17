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
    @State private var isShowShareSheet = false
    
    @State var editedBee: Bumblebee?
    @State var changesToDetections = false
    
    @State var gifUrl: URL?
    
    @State var interpolThreshold: CGFloat = 0.01
    
    @State var detections: Int = 0
    @State var interpolations: Int = 0
    @State var time: Double = 0.0
    
    var body: some View {
        ZStack() {
            ScrollView {
                ProfilePictureAndBackground(
                    profilePicture: newBee.profileImage ?? newBee.backgroundImage ?? UIImage(named: "placeholderBee.png")!,
                    backgroundPicture: newBee.backgroundImage,
                    location: newBee.location,
                    loading: self.isShowActivity
                ).frame(width: UIScreen.main.bounds.width)
                
                Button(action: {
//                    self.gifUrl = UIImage.animatedGif(from: newBee.detections)
                    self.isShowShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }.disabled(newBee.detections.isEmpty)
                .sheet(isPresented: $isShowShareSheet, content: {
                    ShareSheet(activityItems: shareSheetContent())
                })
                
                VStack(spacing: 10.0) {
                    HStack {
                        Text("Name:")
                            .font(.headline)
                        
                        TextField("Enter a nickname", text: $newBee.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .id("nameTextField")
                    }
                    
                    if let beeDate = newBee.date {
                        DetailRow(
                            title: "Date spotted",
                            caption: Utils.itemFormatter.string(from: beeDate))
                    }
                    
                    if !newBee.detections.isEmpty {
                        DetailRow(
                            title: "Detections",
                            caption: "\(self.detections)")
                        
                        DetailRow(
                            title: "Interpolations",
                            caption: "\(self.interpolations)")
                        
                        DetailRow(
                            title: "Time it took",
                            caption: "\(self.time) s")
                        
                        HStack {
                            Text("Detected bee:")
                                .font(.headline)
                            
                            Spacer()
                            
                            AnimationView(
                                imageSize: CGSize(width: 200, height: 200),
                                animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 30))
                            ).frame(width: 200, height: 200, alignment: .center)
                        }
                    }
                }.padding()
                
//                if self.newBee.detections.isEmpty {
                    VStack {
                        VStack {
                            Text("\(self.interpolThreshold)")
                            Slider(value: $interpolThreshold, in: 0...0.05)
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 10.0) {
                            FilledButton(
                                title: "Select a video",
                                disabled: self.isShowActivity
                            ) {
                                self.isShowActionSheet = true
                            }
                            
                            FilledButton(
                                title: "Detect",
                                disabled: self.isShowActivity
                            ) {
                                detectPressed()
                            }
                            
                            FilledButton(
                                title: "Inter",
                                disabled: self.isShowActivity
                            ) {
                                interpolatePressed()
                            }
                        }
                        .padding()
                        .shadow(radius: 7)
                    }.sheet(isPresented: $isShowImagePicker, onDismiss: { videoPicked() }) {
                        ImagePicker(sourceType: imagePickerMediaType, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
                    }
//                }
            }
            .navigationBarTitle("Track a new bee")
            
        }.modifier(PhotoSelectActionSheet(
                    presented: $isShowActionSheet,
                    imagePickerMediaType: $imagePickerMediaType,
                    isShowImagePicker: $isShowImagePicker
        ))
        .toolbar {
            Button("Save") { savePressed() }.disabled(self.newBee.videoURL == nil || self.isShowActivity)
        }
    }
}


extension AddBeeView {
    func shareSheetContent() -> [Any] {
        var shareItems: [Any] = []
        
//        for image in newBee.detections {
//            if let jpegData = image.jpegData(compressionQuality: 0.7) {
//                shareItems.append(jpegData)
//            }
//        }
        
        shareItems.append(UIImage.animatedGif(from: newBee.detections) ?? "no gif :(")
        
        shareItems.append("detections: \(detections)")
        shareItems.append("interpolations: \(interpolations)")
        shareItems.append("time: \(time)")
        
        return shareItems
    }
    
    func videoPicked() {
        if let url = newBee.videoURL {
            let newBeeMetadata = Utils.getVideoMetadata(url: url)
            
            newBee.backgroundImage = newBeeMetadata.firstFrame
            newBee.date = newBeeMetadata.date
            newBee.location = newBeeMetadata.location
        }
    }
    
    func detectPressed() {
        if let url = newBee.videoURL {
            self.isShowActivity = true
            self.changesToDetections = true
            
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
    
    func interpolatePressed() {
        if let url = newBee.videoURL {
            self.isShowActivity = true
            self.changesToDetections = true
            
            self.newBee.detections = []
            
            DispatchQueue(label: "beeInterpolation").async {
                let interpolator = Interpolation(videoUrl: url)
                
                newBee.detections = interpolator.detectByInterpolation(fps: 16, threshold: interpolThreshold)
                
                if let firstImage = newBee.detections.first {
                    newBee.profileImage = firstImage
                }

                // get the background image
//                newBee.backgroundImage = localiser.getFirstFrame()
                
                self.detections = interpolator.detections
                self.interpolations = interpolator.interpolations
                self.time = interpolator.time
                
                self.isShowActivity = false
            }
        }
    }
    
    func savePressed() {
        viewContext.performAndWait {
            if let editedB = editedBee {
                // editing
                editedB.date = newBee.date
                editedB.name = newBee.name
                editedB.videoURL = newBee.videoURL
                editedB.backgroundImage = newBee.backgroundImage
                editedB.profileImage = newBee.profileImage
                editedB.location = newBee.location
                
                if changesToDetections {
                    editedB.detections = newBee.detections
                }
            } else {
                // creating a new bee
                let newBumblebee = Bumblebee(context: viewContext)
                newBumblebee.id = UUID()
                newBumblebee.name = newBee.name
                newBumblebee.date = newBee.date
                newBumblebee.videoURL = newBee.videoURL
                newBumblebee.backgroundImage = newBee.backgroundImage
                newBumblebee.profileImage = newBee.profileImage
                newBumblebee.detections = newBee.detections
                newBumblebee.location = newBee.location
            }
            
            try? viewContext.save()
            presentationMode.wrappedValue.dismiss()
        }
    }
}


struct AddBeeView_Previews: PreviewProvider {
    static let placeholderBee = BumblebeeEdit(
        profileImage: UIImage(named: "placeholderBee.png")!
    )
    static let exampleBee = BumblebeeEdit(
        name: "Theresa",
        date: Date(),
        profileImage: UIImage(named: "frame1.png")!,
        backgroundImage: UIImage(named: "background.png"),
        location: CLLocationCoordinate2D(latitude: 51.519581, longitude: -0.127002),
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
