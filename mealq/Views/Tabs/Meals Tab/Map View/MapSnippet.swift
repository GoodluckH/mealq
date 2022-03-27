//
//  MapSnippet.swift
//  mealq
//
//  Created by Xipu Li on 2/26/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapSnippet: View {
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.75773, longitude: -73.985708), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    var meal: Meal
    
    init(meal: Meal) {
        self.meal = meal
        if let place = meal.place {
            self.region = MKCoordinateRegion(center: place.placemark.location!.coordinate, latitudinalMeters: 0.5, longitudinalMeters: 0.5)
        }
    }
    
    
    var body: some View {
        
            Button(action: {
            withAnimation{
                sharedMapViewManager.showDetailedMapView = true}
                
            }) {
                if let place = meal.place {
                    ZStack {
                        MapSnapshotView(location: place.placemark.location!.coordinate)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius))
                        Image(systemName: "mappin")
                            .foregroundColor(.green)
                            .font(.title)
                            .offset(y: -7)
          
                    }.aspectRatio(2, contentMode: .fit)
                        .fullScreenCover(isPresented: $sharedMapViewManager.showDetailedMapView) {
                            MapView(meal: meal)
                        }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius)
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2))
                            .padding()
               
                            VStack{
                                Image(systemName: "mappin.and.ellipse")
                                 .customFont(name: "Quicksand-Bold", style: .title1, weight: .bold)
                                
                                Text("Add a location")
                                    .customFont(name: "Quicksand-Semibold", style: .body, weight: .bold)
                                    .padding(.top, Constants.tightStackSpacing)
                            } .foregroundColor(.gray)
                   
          
                    }.aspectRatio(2, contentMode: .fit)
                        .fullScreenCover(isPresented: $sharedMapViewManager.showDetailedMapView) {
                            MapView(meal: meal)
                        }
                }
         
            }

        
        



    }
}
//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapSnippet()
//    }
//}
