//
//  DetailedMapView.swift
//  mealq
//
//  Created by Xipu Li on 2/26/22.
//

import SwiftUI
import MapKit
import CoreLocationUI



struct DetailedMapView: UIViewRepresentable {
    @EnvironmentObject var mapData: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return DetailedMapView.Coordinator()
    }
        
    func makeUIView(context: Context) -> MKMapView {
        let view = mapData.mapView
        view.showsUserLocation = true
        view.delegate = context.coordinator
        view.showsCompass = false
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
    }
}



