//
//  MapView.swift
//  BumblebeeDetector
//
//  Created by Marcin Kiliszek on 02/03/2021.
//

import SwiftUI
import MapKit

struct LocationItem: Identifiable {
    let coordinate: CLLocationCoordinate2D
    let id = UUID()
}

struct MapView: View {
    let coordinate: CLLocationCoordinate2D
    
    @State private var region = MKCoordinateRegion()
    @State private var annotationItems: [LocationItem] = []
    
    var body: some View {
        Map(coordinateRegion: $region,
            annotationItems: annotationItems
        ) { item in
            MapPin(coordinate: item.coordinate)
        }
        .frame(height: 400.0)
        .onAppear {
            setRegion(coordinate)
        }
    }
    
    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        annotationItems = [LocationItem(coordinate: coordinate)]
    }
}

struct MapView_Previews: PreviewProvider {
    static let britishMuseum = CLLocationCoordinate2D(latitude: 51.519581, longitude: -0.127002)
    
    static var previews: some View {
        MapView(coordinate: britishMuseum)
    }
}
