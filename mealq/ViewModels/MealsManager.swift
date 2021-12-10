//
//  ChatsManager.swift
//  mealq
//
//  Created by Xipu Li on 12/7/21.
//

import Foundation
import Firebase
import FirebaseAuth

/// A manager to handle fething group chat (meal) requests, sending messages, updating friends activities, etc.
class MealsManager: ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var pendingMeals = [MealqUser]()
    
    
    
    
    
    
    
    
    @Published var sendingMealRequest = Status.idle
    /// Sends a meal request to an array of users by adding the request to "pendingMeals" subcollection under "users" collection;
    /// the accompanied variable  `sendingMealRequest` is a progress indicator of this function to facilate with UI changes.
    ///
    /// - parameter users: an array of `MealqUser` that are friends with the current user.
    /// - parameter me: the current user.
    /// - parameter weekday: an integer representation of the weekday (optional).
    /// - parameter mealName: the name for the meal.
    func sendMealRequest(to users: [MealqUser], from me: MealqUser, on weekday: Int?, mealName: String) {
        sendingMealRequest = .loading
        
        if let _ = Auth.auth().currentUser  {
            let payload = ["from": me.id,
                           "to": users.map{$0.id},
                           "name": mealName.isEmpty ? "a meal" : mealName,
                           "userStatus": users.map{[$0.id:"pending"]},
                           "weekday": weekday ?? 0
            ] as [String : Any]
            
            self.db.collection("chats").document().setData(payload) {err in
                if let err = err {
                    self.sendingMealRequest = .error //DEBUG: Change it to .done
                    print("Something went wrong when sending meal request: \(err.localizedDescription)")
                    return
                } else {
                    self.sendingMealRequest = .done
                    print("Successfully sent meal request!")
                    return
                }
            }
            
        } else {
            print("Could not fetch current user when sending meal request")
            self.sendingMealRequest = .error
            return
        }
    }
    
    
    
    enum Status {
        case idle, loading, done, error
    }
    
    
}
