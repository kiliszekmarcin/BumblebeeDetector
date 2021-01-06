//
//  ContentView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 05/01/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var bees: [Bumblebee] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bees, id: \.date) { bee in
                    HStack{
                        Image(uiImage: bee.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                        Text("Date:")
                        Text(bee.date.description(with: nil))
                    }
                }
            }
                
            .navigationBarTitle("Idk")
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
            .previewDevice("iPhone 12")
    }
}
