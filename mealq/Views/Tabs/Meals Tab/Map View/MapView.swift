//
//  MapView.swift
//  mealq
//
//  Created by Xipu Li on 3/5/22.
//

import SwiftUI
import CoreLocation


struct MapView: View {
    @StateObject var mapData = MapViewModel()
    @State var locationManager = CLLocationManager()
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager

    var body: some View {
        ZStack {
            DetailedMapView()
                .ignoresSafeArea(.all, edges: .all)
                .onAppear {
                    locationManager.delegate = mapData
                    locationManager.requestWhenInUseAuthorization()
                }
                .alert(isPresented: $sharedMapViewManager.permissionDenied) {
                    Alert(title: Text("Permission Denied"),
                          message: Text("Please enable location services in the settings."),
                          dismissButton: .default(Text("Go to Settings")){
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                }
            
            VStack {
                MapSearchBar()
                
                Spacer()
                Button(action: {mapData.focusLocation()}) {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(Constants.tightStackSpacing * 5)
                        .background(Color("QueryLoaderStartingColor"))
                        .foregroundColor(Color("MyPrimary"))
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: Constants.roundedRectShadowRadius)
                        
                }.frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    .padding(.bottom)
            }
          
        }.environmentObject(mapData)

    }
}
