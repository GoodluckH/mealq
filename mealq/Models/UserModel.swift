//
//  UserModel.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import Foundation
import Combine
import Firebase

/// A model for the current user.
struct MealqUser: Identifiable, Codable, Hashable {
    var id: String
    var fullname: String
    var email: String
    var thumbnailPicURL: URL?
    var normalPicURL: URL?
    var fcmToken: String?
    
    
    static func == (lhs: MealqUser, rhs: MealqUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


//struct FriendRequest: Identifiable, Codable, Hashable {
//    var id: String
//    var fullname: String
//    var email: String
//    var thumbnailPicURL: URL?
//    var normalPicURL: URL?
//    var fcmToken: String?
//    var createdAt: Date
//
//    static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
