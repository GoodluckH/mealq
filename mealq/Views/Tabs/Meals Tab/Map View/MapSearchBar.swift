//
//  MapSearchBar.swift
//  mealq
//
//  Created by Xipu Li on 3/5/22.
//

import SwiftUI

struct MapSearchBar: View
{
    private let searchBarShadowRadius: CGFloat = 5
    private let searchBarShadowYOffset: CGFloat = 2
    
    @ObservedObject private var sharedMapViewManager = MapViewManager.sharedMapViewManager
    @EnvironmentObject var mapData: MapViewModel
    
    @FocusState var isFocused: Bool
    @Namespace var ns
    
    var body: some View {
        HStack {
            
            if !isFocused {
                Button(action: {sharedMapViewManager.showDetailedMapView = false}) {
                    Image(systemName: "xmark")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color("MyPrimary"))
                        .padding(9)
                        .background()
                        .clipShape(Circle())
                        .shadow(color: .gray, radius: searchBarShadowRadius, y: searchBarShadowYOffset)
                        .padding([.leading, .top, .bottom])
                        .matchedGeometryEffect(id: "search", in: ns)
                }
            }
       
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Color("MyPrimary"))
                TextField("search for a place", text: $mapData.searchText)
                        .placeholder("search for a place", when: mapData.searchText.isEmpty)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .frame(alignment: .leading)
                        .focused($isFocused)
                        .foregroundColor(Color("MyPrimary"))
                        .accentColor(Color("MyPrimary"))
                        .disableAutocorrection(true)
                Spacer()
                if isFocused && !mapData.searchText.isEmpty {
                    Button(action: {mapData.searchText = ""}) {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.gray)
                            .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
                .padding(.vertical, 7.0)
                .padding(.horizontal, 10.0)
                .background(Color("QueryLoaderStartingColor"))
                .clipShape(Capsule())
                .padding(isFocused ? [.trailing, .top, .bottom, .leading] : [.trailing, .top, .bottom])
                .shadow(color: .gray, radius: searchBarShadowRadius, y: searchBarShadowYOffset)

        }
        
   
    }
}

struct MapSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchBar()
    }
}
