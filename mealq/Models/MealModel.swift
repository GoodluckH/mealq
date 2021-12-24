//
//  MealModel.swift
//  mealq
//
//  Created by Xipu Li on 12/23/21.
//

import Foundation
import Combine


/// A data model for meals.
struct Meal: Identifiable, Codable, Hashable {
    
    var id: String
    var name: String
    var from: String // the uid of the meal invitor
    var to: [MealqUser: String]
    var weekday: Int
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
