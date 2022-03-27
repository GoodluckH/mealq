//
//  MealModel.swift
//  mealq
//
//  Created by Xipu Li on 12/23/21.
//

import Foundation
import Combine

/// A data model for meals.
struct Meal: Identifiable, Hashable {
     
    var id: String
    var name: String
    var from: MealqUser
    var to: [MealqUser: String]
    var weekday: Int
    var createdAt: Date
    var recentMessageID: String
    var recentMessageContent: String
    var sentByName: String
    var messageTimeStamp: Date
    var unreadMessages: Int
    var specificDate: Date?
    var place: Place? 
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}


// status: accepted, pending, declined
