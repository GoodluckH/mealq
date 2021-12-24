//
//  ChatsManager.swift
//  mealq
//
//  Created by Xipu Li on 12/7/21.
//

import Foundation
import Firebase
import FirebaseMessaging
import FirebaseAuth

/// A manager to handle fething group chat (meal) requests, sending messages, updating friends activities, etc.
class MealsManager: ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var pendingMeals = [Meal]()
    @Published var acceptedMeals = [Meal]()
    // @Published var rejectedMeals = [Meal]()
    
    /// Fetches meals from the current user's "meals" collection;
    /// If the status on the database shows "pending", then construct a `Meal` model and append it to `pendingMeals`;  similarly for "accepted" meals
    ///
    /// - SeeAlso: `Meal`, `pendingMeals`, `acceptedMeals`, `addMeal`
    func fetchMeals() {
        if let currentUser = Auth.auth().currentUser {
            self.db.collection("users").document(currentUser.uid).collection("meals").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("no meals :(  --- failed to retrieve snapshot")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    let status = data["status"] as! String
                    self.addMeal(document.documentID, to: status)
                }
        
            }
        }
    }
    
    
    /// Construct a `Meal` model and append it to the designated array.
    ///
    /// - parameter docID: the id of the meal.
    /// - parameter array: the array to append the `Meal`.
    private func addMeal(_ docID: String, to array: String) {
        db.collection("chats").document(docID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let name = data["name"] as! String
                let id = data["mealID"] as! String
                let from = data["from"] as! String
                let weekday = data["weekday"] as! Int
                let userStatus = data["userStatus"] as! [String: String]
                var to = [MealqUser: String]()
                
                for userID in data["to"] as! [String] {
                    self.db.collection("users").document(userID).getDocument{ (document, error) in
                        if let document = document, document.exists {
                            let userData = document.data()!
                            to[MealqUser(id: userID,
                                         fullname: userData["fullname"] as! String,
                                         email: userData["email"] as! String,
                                         thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                         normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                         fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[userID]
                        } else {
                            print("The document for user \(userID) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
               
                if array == "pending" {self.pendingMeals.append(Meal(id: id, name: name, from: from, to: to, weekday: weekday))}
                if array == "accepted" {self.acceptedMeals.append(Meal(id: id, name: name, from: from, to: to, weekday: weekday))}
                
                

            } else {
                print("The document for meal \(docID) does not exist")
            }
            
        }
    }
    
    
    
    
    
    
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
            
            
            let newMeal = self.db.collection("chats").document()
            
            let payload = ["mealID": newMeal.documentID,
                           "from": me.id,
                           "to": users.map{$0.id},
                           "name": mealName.isEmpty ? "a meal" : mealName,
                           "userStatus": users.reduce(into: [String: String]()){$0[$1.id] = "pending"},
                           "weekday": weekday ?? 0
            ] as [String : Any]
            
            
            newMeal.setData(payload) {err in
                if let err = err {
                    self.sendingMealRequest = .error //DEBUG: Change it to .done
                    print("Something went wrong when sending meal request: \(err.localizedDescription)")
                    return
                } else {
                    self.sendingMealRequest = .done // REMEMBER TO MOVE IT TO MESSAGING
                    print("Successfully sent meal request to Firestore!")
                }
            }
            
            
            // start batch writing meals to each of the invited users
            let batch = self.db.batch()
            
            
            for user in users {
                batch.setData(["status": "pending"], forDocument: self.db.collection("users").document(user.id).collection("meals").document(newMeal.documentID))
            }
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
            
            
            // Subscribe all invited users to a FCM topic named by the newMeal's docID
//            Messaging.messaging().subscribe(toTopic: newMeal.documentID) { error in
//                if let error = error {
//                    print("Unable to subscribe current user to FCM topic: \(error.localizedDescription)")
//                    self.sendingMealRequest = .error
//                } else {
//                    self.sendingMealRequest = .done
//                    print("Successfully subscribed the current user to FCM topic: \(newMeal.documentID)")
//                }
//
//            }
            
            
        } else {
            print("Could not fetch current user when sending meal request")
            self.sendingMealRequest = .error
        }
    }
    
    
    
    enum Status {
        case idle, loading, done, error
    }
    
    
}
