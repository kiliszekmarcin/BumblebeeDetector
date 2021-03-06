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
    
    var researchMode: Bool
    
    @State var newBee = BumblebeeEdit()

    @State private var isShowImagePicker = false
    @State private var imagePickerMediaType = UIImagePickerController.SourceType.photoLibrary
    @State private var isShowActionSheet = false
    @State private var isShowActivity = ""
    
    @State var editedBee: Bumblebee?
    @State var changesToDetections = false
    
    @State var imagesToSend: Double = 13
    @State var selectionMethod: Method = .belowAverage
    
    @State var selectedImages: [UIImage] = []
    
    @State var interpolate: Bool = false
    @State var threshold: CGFloat = 0.025
    
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
                            caption: Utils.dateTimeFormatter.string(from: beeDate))
                    }
                    
                    if !newBee.detections.isEmpty {
                        HStack {
                            Text("Detected bee:")
                                .font(.headline)
                            
                            Spacer()
                            
                            AnimationView(
                                imageSize: CGSize(width: 200, height: 200),
                                animatedImage: UIImage.animatedImage(with: newBee.detections, duration: TimeInterval(newBee.detections.count / 20))
                            ).frame(width: 200, height: 200, alignment: .center)
                            .cornerRadius(11)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 7)
                        }
                        
                        if researchMode && newBee.videoURL != nil {
                            if self.detections != 0 || self.interpolations != 0 || self.time != 0.0 {
                                DetailRow(
                                    title: "Detections",
                                    caption: "\(self.detections)")
                                
                                DetailRow(
                                    title: "Interpolations",
                                    caption: "\(self.interpolations)")
                                
                                DetailRow(
                                    title: "Time it took",
                                    caption: String(format: "%.2f", self.time) + " s")
                            }
                            
                            if !self.selectedImages.isEmpty {
                                HStack {
                                    Text("Selected frames:")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    AnimationView(
                                        imageSize: CGSize(width: 200, height: 200),
                                        animatedImage: UIImage.animatedImage(with: self.selectedImages, duration: TimeInterval(2))
                                    ).frame(width: 200, height: 200, alignment: .center)
                                    .cornerRadius(15)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 7)
                                }
                            }
                            
                            Button("Predict using \(Int(self.imagesToSend)) frames") {
                                self.selectedImages = []
                                sendImagesToAPI()
                            }.accessibility(identifier: "Predict")
                            Slider(value: $imagesToSend, in: 1...20, step: 1)
                                .padding(.horizontal)
                            
                            Picker("Selection method", selection: $selectionMethod) {
                                ForEach(Method.allCases, id: \.id) { method in
                                    Text(method.rawValue)
                                        .tag(method)
                                }
                            }
                        }
                        
                        if !newBee.predictions.isEmpty {
                            HStack {
                                Text("Predictions:")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            ForEach(newBee.predictions.filter { $0.confidence >= 0.1 }, id: \.self) { prediction in
                                HStack {
                                    Text(prediction.species + ":")
                                    Text(String(format: "%.2f", prediction.confidence*100) + "%")
                                    Spacer()
                                }
                            }
                        }
                    }
                }.padding()
                
                // detection controlls
                if editedBee == nil {
                    if researchMode && newBee.videoURL != nil {
                        Toggle(isOn: $interpolate) {
                            Text("Interpolate")
                                .font(.headline)
                        }.padding(.horizontal)
                        
                        if self.interpolate {
                            VStack {
                                Text("\(self.threshold)")
                                Slider(value: $threshold, in: 0...0.05)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    VStack {
                        HStack(spacing: 10.0) {
                            FilledButton(
                                title: "Select a video",
                                disabled: self.isShowActivity != ""
                            ) {
                                self.isShowActionSheet = true
                            }
                            
                            FilledButton(
                                title: "Detect",
                                disabled: self.isShowActivity != "" || (newBee.videoURL == nil && newBee.profileImage == nil)
                            ) {
                                detectPressed()
                            }
                        }
                        .padding()
                        .shadow(radius: 7)
                    }
                }
            }
            .navigationBarTitle(newBee.name == "" ? "Add a new bee" : newBee.name)
            
        }.actionSheet(isPresented: $isShowActionSheet) {
            ActionSheet(
                title: Text("Select video source"),
                message: nil,
                buttons: [
                    ActionSheet.Button.default(Text("Photo Library"), action: {
                        self.imagePickerMediaType = .photoLibrary
                        self.isShowImagePicker = true
                    }),
                    ActionSheet.Button.default(Text("Camera"), action: {
                        self.imagePickerMediaType = .camera
                        self.isShowImagePicker = true
                    }),
                    ActionSheet.Button.cancel()
                ])
        }.sheet(isPresented: $isShowImagePicker, onDismiss: { beePicked() }) {
            ImagePicker(sourceType: imagePickerMediaType, selectedImage: self.$newBee.profileImage, selectedVideoUrl: self.$newBee.videoURL)
        }
        .toolbar {
            Button("Save") { savePressed() }.disabled(self.newBee.videoURL == nil || self.isShowActivity != "" || self.newBee.detections.isEmpty)
        }
    }
}


extension AddBeeView {
    func beePicked() {
        if let url = newBee.videoURL {
            // video
            let newBeeMetadata = Utils.getVideoMetadata(url: url)
            
            newBee.backgroundImage = newBeeMetadata.firstFrame
            newBee.date = newBeeMetadata.date
            newBee.location = newBeeMetadata.location
        } else if let photo = newBee.profileImage {
            // photo
            newBee.backgroundImage = photo
        }
    }
    
    func detectPressed() {
        if let url = newBee.videoURL {
            // video
            self.isShowActivity = "Detecting"
            self.changesToDetections = true
            
            self.newBee.detections = []
            self.newBee.predictions = []
            
            DispatchQueue(label: "beeDetection").async {
                self.time = 0.0
                self.detections = 0
                self.interpolations = 0
                let detectionStart = Date()
                
                if interpolate {
                    let interpolator = Interpolation(videoUrl: url)
                    
                    newBee.detections = interpolator.detectByInterpolation(fps: 16, threshold: threshold)
                    
                    if let firstImage = newBee.detections.first {
                        newBee.profileImage = firstImage
                    }
                    
                    self.detections = interpolator.detections
                    self.interpolations = interpolator.interpolations
                } else {
                    let localiser = BeeLocaliser()
                    
                    newBee.detections = localiser.detectBee(onVideo: url, fps: 16)
                    
                    if let profilePic = localiser.profilePicture {
                        newBee.profileImage = profilePic
                    }
                    
                    self.detections = localiser.detections
                }
                
                self.time = -detectionStart.timeIntervalSinceNow
                
                self.isShowActivity = ""
                
                if !researchMode {
                    sendImagesToAPI()
                }
            }
        } else if let photo = newBee.profileImage {
            // photo
            self.isShowActivity = "Detecting"
            self.changesToDetections = true
            
            self.newBee.detections = []
            self.newBee.predictions = []
            
            DispatchQueue(label: "beeDetection").async {
                let localiser = BeeLocaliser()
                
                if let cgPhoto = photo.cgImage,
                   let detection = localiser.detectBeeImg(onImage: cgPhoto) {
                    newBee.detections = [detection]
                }
                
                if let profilePic = localiser.profilePicture {
                    newBee.profileImage = profilePic
                }
                
                self.isShowActivity = ""
                sendImagesToAPI()
            }
        }
    }
    
    func sendImagesToAPI() {
        self.isShowActivity = "Predicting"
        
        self.newBee.predictions = []
        
        DispatchQueue(label: "request").async {
            self.selectedImages = Requests.sendImages(images: newBee.detections, imagesToSend: Int(self.imagesToSend), method: selectionMethod) { json in
                // parse json into the classifications array
                newBee.predictions = Utils.anyJsonToPredictions(json: json)
                
                self.isShowActivity = ""
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
                AddBeeView(researchMode: true, newBee: exampleBee)
            }.previewDevice("iPhone 12").previewDisplayName("Example bee")
            
            NavigationView {
                AddBeeView(researchMode: true, newBee: placeholderBee)
            }.previewDevice("iPhone 12").previewDisplayName("Placeholder")
        }
    }
}
