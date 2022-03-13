//
//  MapViewModel.swift
//  mealq
//
//  Created by Xipu Li on 2/27/22.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Firebase
import GeoFire
import GeoFireUtils

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager
    
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    
    @Published var searchText = ""
    let locationManager = CLLocationManager()

    @Published var places: [Place] = []
    
    private var db = Firestore.firestore()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAllowOnceLocationPermission() {
        locationManager.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.locationManager.stopUpdatingLocation()

        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
         return
        }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000,  longitudinalMeters: 2000)
            self.mapView.setRegion(self.region, animated: false)
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func searchPlaces() {
        places = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else {return}
            self.places = result.mapItems.compactMap { item in
                return Place(placemark: item.placemark)
            }
        }
    }
    
    func selectPlace(place: Place) {
        searchText = ""
        guard let coordinate = place.placemark.location?.coordinate else {return}
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No Name"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pointAnnotation)
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        
    }
    
    func removePin() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func setPlaceLocation(mealID: String) {
        if let _ = Auth.auth().currentUser {
            let location = mapView.annotations.first!.coordinate

            self.db.collection("chats").document(mealID).updateData(["location": GeoPoint(latitude: location.latitude, longitude: location.longitude)]) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            // alert user
            sharedMapViewManager.permissionDenied = true
        case .notDetermined:
            // requesting
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            sharedMapViewManager.permissionDenied = false
            locationManager.startUpdatingLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.locationManager.stopUpdatingLocation()

            }
        default:
        ()
        }
    }

    func focusLocation() {
        guard let _ = region else {return}
        mapView.setRegion(region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    


}
