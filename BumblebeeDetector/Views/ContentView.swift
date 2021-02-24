//
//  ContentView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Bumblebee.entity(), sortDescriptors: [])
    
    private var bumblebees: FetchedResults<Bumblebee>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bumblebees, id: \.id) { bee in
                    HStack{
                        Image(uiImage: bee.profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                        Text("Date: \(bee.date, formatter: itemFormatter)")
                    }
                }
            }
                
            .navigationBarTitle("Detections")
            .navigationBarItems(trailing:
                NavigationLink(destination: AddBeeView()) {
                    Image(systemName: "plus")
                }
            )
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone 12")
    }
}
