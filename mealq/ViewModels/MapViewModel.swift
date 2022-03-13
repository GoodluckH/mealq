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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager
    
    @Published var mapView = MKMapView()
    @Published var region: MKCoordinateRegion!
    
    @Published var searchText = ""
    let locationManager = CLLocationManager()

    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAllowOnceLocationPermission() {
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
         return
        }
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000,  longitudinalMeters: 10000)
        self.mapView.setRegion(self.region, animated: false)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: false)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
            manager.startUpdatingLocation()
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
