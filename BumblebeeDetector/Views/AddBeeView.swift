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
    @State var changesToDetections = false
    
    @State var gifUrl: URL?
    
    @State var interpolOn: Bool = false
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
                            caption: String(format: "%.2f", self.time) + " s")
                        
                        HStack {
                            Text("Detected bee:")
                                .font(.headline)
                            
                            Spacer()
                            
                            AnimationView(
                                imageSize: CGSize(width: 200, height: 200),
                                animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 30))
                            ).frame(width: 200, height: 200, alignment: .center)
                        }
                        
                        Text("Predictions:")
                            .font(.headline)
                        ForEach(newBee.predictions.filter { $0.confidence >= 0.1 }, id: \.self) { prediction in
                            HStack {
                                Text(prediction.species + ":")
                                Text(String(format: "%.2f", prediction.confidence*100) + "%")
                                Spacer()
                            }
                        }
                    }
                }.padding()
                
                VStack {
                    Toggle(isOn: $interpolOn) {
                        Text("Interpolation:")
                            .font(.headline)
                    }.padding()
                    
                    if self.interpolOn {
                        VStack {
                            Text("\(self.interpolThreshold)")
                            Slider(value: $interpolThreshold, in: 0...0.05)
                                .padding(.horizontal)
                        }
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
                            if self.interpolOn {
                                interpolatePressed()
                            } else {
                                detectPressed()
                            }
                        }
                    }
                    .padding()
                    .shadow(radius: 7)
                }.sheet(isPresented: $isShowImagePicker, onDismiss: { videoPicked() }) {
                    ImagePicker(sourceType: imagePickerMediaType, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
                }
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
            
            self.newBee.detections = []
            self.newBee.predictions = []
            
            DispatchQueue(label: "beeDetection").async {
                self.time = 0.0
                let detectionStart = Date()
                
                let localiser = BeeLocaliser()
                
                newBee.detections = localiser.detectBee(onVideo: url, fps: 16)
                
                if let firstImage = newBee.detections.first {
                    newBee.profileImage = firstImage
                }
                
                // get the background image
                newBee.backgroundImage = localiser.getFirstFrame()
                
                self.detections = localiser.frames
                self.interpolations = 0
                self.time = -detectionStart.timeIntervalSinceNow
                
                sendImagesToAPI()
                
//                self.isShowActivity = false // handled in sendImagesToAPI
            }
        }
    }
    
    func interpolatePressed() {
        if let url = newBee.videoURL {
            self.isShowActivity = true
            self.changesToDetections = true
            
            self.newBee.detections = []
            
            DispatchQueue(label: "beeInterpolation").async {
                self.time = 0.0
                let interpolationStart = Date()
                
                let interpolator = Interpolation(videoUrl: url)
                
                newBee.detections = interpolator.detectByInterpolation(fps: 16, threshold: interpolThreshold)
                
                if let firstImage = newBee.detections.first {
                    newBee.profileImage = firstImage
                }

                // get the background image
//                newBee.backgroundImage = localiser.getFirstFrame()
                
                self.detections = interpolator.detections
                self.interpolations = interpolator.interpolations
                self.time = -interpolationStart.timeIntervalSinceNow
                
                self.isShowActivity = false
            }
        }
    }
    
    func sendImagesToAPI() {
//        self.isShowActivity = true
        
        Requests.sendImages(images: newBee.detections) { json, error in
            // parse json into the classifications arry
            if let jsonDict = json as? [String: Any] {
                if let jsonDeeper = jsonDict["pred"] as? [Any] {
                    for item in jsonDeeper {
                        if let item = item as? [Any] {
                            let species = item[0] as! String
                            let confidence = item[1] as! Double
                            
                            newBee.predictions.append(Prediction(species: species, confidence: confidence))
                        }
                    }
                }
            }
        }
        
        self.isShowActivity = false
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
                editedB.predictions = newBee.predictions
                
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
                newBumblebee.predictions = newBee.predictions
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
        ],
        predictions: [
            Prediction(species: "Bombus sylvestris", confidence: 0.3546587824821472),
            Prediction(species: "Bombus hortorum", confidence: 0.27430015802383423),
            Prediction(species: "Bombus campestris", confidence: 0.2058732956647873),
            Prediction(species: "Bombus vestalis", confidence: 0.08856615424156189),
            Prediction(species: "Bombus lucorum", confidence: 0.06423360109329224)
        ]
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                AddBeeView(newBee: exampleBee)
            }.previewDevice("iPhone 12").previewDisplayName("Example bee")
            
            NavigationView {
                AddBeeView(newBee: placeholderBee)
            }.previewDevice("iPhone 12").previewDisplayName("Placeholder")
        }
    }
}
