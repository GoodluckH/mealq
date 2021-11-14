//
//  UserModel.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import Foundation
import Combine

/// A model for the current user.
struct MealqUser: Identifiable, Codable, Hashable {
    var id: String
    var fullname: String
    var email: String
    var thumbnailPicURL: URL?
    var normalPicURL: URL?
    
    static func == (lhs: MealqUser, rhs: MealqUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
