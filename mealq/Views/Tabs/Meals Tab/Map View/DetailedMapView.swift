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
    let meal: Meal
    
    init(meal: Meal){
        self.meal = meal
    }
    func makeCoordinator() -> Coordinator {
        if let place = meal.place {
            self.mapData.mealPlace = place
            self.mapData.selectPlace(place: place)
        }
        return DetailedMapView.Coordinator(mapData: mapData, meal: meal)
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
        let mapData: MapViewModel
        let meal: Meal
        init(mapData: MapViewModel, meal:Meal) {
            self.mapData = mapData
            self.meal = meal
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.isKind(of: MKUserLocation.self) {return nil}
            else {
                let pinAnnoation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
                
                if let place = meal.place {
                    if place.placemark.location!.coordinate.latitude == annotation.coordinate.latitude
                    && place.placemark.location!.coordinate.longitude == annotation.coordinate.longitude {
                        // do nothing
                        let leftButton = UIButton(type: .close)
                        leftButton.tag = annotation.hash
                        leftButton.addTarget(self, action: #selector(removeMealPin), for: .touchUpInside)
                        pinAnnoation.leftCalloutAccessoryView = leftButton
                        
                        pinAnnoation.pinTintColor = .green
                        
                    }
                    else  {
                        let rightButton = UIButton(type: .contactAdd)
                        rightButton.tag = annotation.hash
                        rightButton.addTarget(self, action: #selector(setLocation), for: .touchUpInside)
                        pinAnnoation.rightCalloutAccessoryView = rightButton
                        
                        let leftButton = UIButton(type: .close)
                        leftButton.tag = annotation.hash
                        leftButton.addTarget(self, action: #selector(removePin), for: .touchUpInside)
                        pinAnnoation.leftCalloutAccessoryView = leftButton
                        
                    }
                } else  {
                    let rightButton = UIButton(type: .contactAdd)
                    rightButton.tag = annotation.hash
                    rightButton.addTarget(self, action: #selector(setLocation), for: .touchUpInside)
                    pinAnnoation.rightCalloutAccessoryView = rightButton
                    
                    let leftButton = UIButton(type: .close)
                    leftButton.tag = annotation.hash
                    leftButton.addTarget(self, action: #selector(removePin), for: .touchUpInside)
                    pinAnnoation.leftCalloutAccessoryView = leftButton
                    
                }

                pinAnnoation.tintColor = .red

                pinAnnoation.animatesDrop = true
                pinAnnoation.canShowCallout = true
                

           
                return pinAnnoation
            }
        }
        
        @objc func removeMealPin(sender: UIButton) {
            mapData.removePin(mealPin: true, mealID: self.meal.id)
        }
        
        @objc func removePin(sender: UIButton) {
            mapData.removePin(mealPin: false, mealID: nil)
        }
        
        @objc func setLocation(sender: UIButton) {
            mapData.setPlaceLocation(mealID: meal.id)
        }
    }
}


