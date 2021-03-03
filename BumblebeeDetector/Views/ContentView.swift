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
                    NavigationLink(destination: AddBeeView(newBee: BumblebeeEdit(bumblebee: bee), editedBee: bee)
                    ) {
                        HStack{
                            Image(uiImage: bee.profileImage ?? bee.backgroundImage ?? UIImage(named: "placeholderBee.png")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                            if let beeDate = bee.date {
                                Text("Date: \(beeDate, formatter: Utils.itemFormatter)")
                            } else {
                                Text("No date info")
                            }
                        }
                    }
                }.onDelete(perform: { indexSet in
                    for index in indexSet {
                        viewContext.delete(bumblebees[index])
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        print("Error when deleting an item")
                        print(error.localizedDescription)
                    }
                })
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone 12")
    }
}
