//
//  BeeRow.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 01/04/2021.
//

import SwiftUI

struct BeeRow: View {
    @ObservedObject var bee: Bumblebee
    
    var body: some View {
        HStack{
            Image(uiImage: bee.profileImage ?? bee.backgroundImage ?? UIImage(named: "placeholderBee.png")!)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                // name field
                Text(bee.name != "" ? bee.name : "No name")
                
                // date
                if let date = bee.date {
                    Text("\(date, formatter: Utils.dateFormatter)")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                
                // prediction field
                if let prediction = bee.predictions.first {
                    Text(String(format: "%.2f", prediction.confidence*100) + "% " + prediction.species)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
}

struct BeeRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBee = try! context.fetch(Bumblebee.fetchRequest()).first as! Bumblebee
        
        Group {
            BeeRow(bee: sampleBee)
                .previewLayout(.sizeThatFits)
                .environment(\.managedObjectContext, context)
            
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .previewDevice("iPhone 12")
        }
    }
}
