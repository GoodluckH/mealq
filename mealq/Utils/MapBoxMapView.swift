//
//  MapBoxMapView.swift
//  mealq
//
//  Created by Xipu Li on 2/26/22.
//

import SwiftUI
import MapboxMaps
import MapboxSearch
import MapboxSearchUI
import UIKit
import CoreLocation

struct MapBoxMapView: UIViewControllerRepresentable {
     
    func makeUIViewController(context: Context) -> MapViewController {
           return MapViewController()
       }
      
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    }
}




class MapViewController: UIViewController {
   internal var mapView: MapView!
    let searchController = MapboxSearchController()
    var annotationManager: PointAnnotationManager?
    
   override public func viewDidLoad() {
       super.viewDidLoad()
      
      
       
       let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiZ29vZGx1Y2toIiwiYSI6ImNrbHZkMnl0aDA3djEyeG8wbWpiMnphOGwifQ.gTYaO-uu46huh_eqhIpqUw")
       let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.83647410051574, longitude: 14.30582273457794), zoom: 4.5)
       let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions:cameraOptions)

     
       mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
       mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       self.view.addSubview(mapView)
       
       searchController.delegate = self
       let panelController = MapboxPanelController(rootViewController: searchController)
       addChild(panelController)
       
       
       annotationManager = mapView.annotations.makePointAnnotationManager()
    
   }
    
    func showResults(_ results: [SearchResult]) {
        
        
        annotationManager?.annotations = results.map { searchResult -> PointAnnotation in
            var annotation = PointAnnotation(coordinate: searchResult.coordinate)
                annotation.textField = searchResult.name
                annotation.textOffset = [0, -2]
                annotation.textColor = StyleColor(.red)
                annotation.image = PointAnnotation.Image.init(image: UIImage(named: "red_pin")!, name: "red_pin")
            return annotation
        }
        annotationManager?.syncSourceAndLayerIfNeeded()
         
        if case let .point(point) = annotationManager?.annotations.first?.geometry {
            let options = CameraOptions(center: point.coordinates)
            mapView?.mapboxMap.setCamera(to: options)
        }
    }
    

}

extension MapViewController: SearchControllerDelegate {
    func categorySearchResultsReceived(category: SearchCategory, results: [SearchResult]) {
        showResults(results)
    }
    
    
    
    func searchResultSelected(_ searchResult: SearchResult) {
        showResults([searchResult])
    }
    func categorySearchResultsReceived(results: [SearchResult]) {
        showResults(results)
    }
    func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
        showResults([userFavorite])
    }
}




