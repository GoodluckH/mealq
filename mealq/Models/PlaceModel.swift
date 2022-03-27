//
//  PlaceModel.swift
//  mealq
//
//  Created by Xipu Li on 3/13/22.
//

import Foundation
import MapKit
import Combine

struct Place: Identifiable  {
    var id = UUID().uuidString
    var placemark: CLPlacemark 
}
