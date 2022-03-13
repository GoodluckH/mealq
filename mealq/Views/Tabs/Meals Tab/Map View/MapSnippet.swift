//
//  MapSnippet.swift
//  mealq
//
//  Created by Xipu Li on 2/26/22.
//

import SwiftUI
import CoreLocation
struct MapSnippet: View {
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager
    var meal: Meal
    var body: some View {
        
            Button(action: {
            withAnimation{
                sharedMapViewManager.showDetailedMapView = true}
                
            }) {
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
//
//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapSnippet()
//    }
//}
