//
//  MapViewManager.swift
//  mealq
//
//  Created by Xipu Li on 2/26/22.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

class MapViewManager:  ObservableObject {
    static var sharedMapViewManager = MapViewManager()
    private init() {}
    @Published var showDetailedMapView = false
    @Published var permissionDenied = false
}
