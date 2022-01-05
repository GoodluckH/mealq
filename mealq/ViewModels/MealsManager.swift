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
    private let user = Auth.auth().currentUser

    @Published var pendingMeals = [Meal]()
    @Published var acceptedMeals = [Meal]()
    // @Published var rejectedMeals = [Meal]()
    
    /// Fetches meals from the current user's "meals" collection;
    /// If the status on the database shows "pending", then construct a `Meal` model and append it to `pendingMeals`;  similarly for "accepted" meals
    ///
    /// - SeeAlso: `Meal`, `pendingMeals`, `acceptedMeals`, `addMeal`
    func fetchMeals() {
        if let currentUser = user {

            self.db.collection("chats").whereField("to", arrayContains: currentUser.uid).addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("failed to retrieve meals snapshot")
                    return
                }
                
                snapshot.documentChanges.forEach {diff in
                    if (diff.type == .added) {
                        let data = diff.document.data()
                        let status = data["userStatus"] as! [String: String]
                        self.addMeal(diff.document.documentID, by: status[currentUser.uid]!)
                    }
                    if (diff.type == .modified) {
                        let data = diff.document.data()
                        let status = data["userStatus"] as! [String: String]
                        let mealID = data["mealID"] as! String
                        
                        if status[currentUser.uid]! == "pending" {
                            self.modifyMeal(diff.document.documentID, by: status[currentUser.uid]!)
                        }

                        if status[currentUser.uid]! == "accepted" {
                            if let idx = self.pendingMeals.firstIndex(where: {$0.id == mealID}) {
                                self.pendingMeals.remove(at: idx)
                                self.addMeal(diff.document.documentID, by: status[currentUser.uid]!)
                            } else {
                                self.modifyMeal(diff.document.documentID, by: status[currentUser.uid]!)
                            }
                        }
                        
                        // TODO: add the logic for rejected meals
                    }
                }
                
//                self.pendingMeals = [Meal]()
//                for document in documents {
//                    let data = document.data()
//                    let status = data["userStatus"] as! [String: String]
//                    self.addMeal(document.documentID, by: status[currentUser.uid]!)
//                }
            }
            
            
        }
    }
    

    
    private func modifyMeal(_ docID: String, by status: String) {
        // get the specific chat from docID
        db.collection("chats").document(docID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let name = data["name"] as! String
                let id = data["mealID"] as! String
                let from = data["from"] as! String
                let weekday = data["weekday"] as! Int
                let userStatus = data["userStatus"] as! [String: String]
                let createdAt = data["createdAt"] as! Timestamp
                
                // fetch user detail info
                self.db.collection("users").document(from).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let userData = document.data()!
                        let fromUser = MealqUser(id: from,
                                     fullname: userData["fullname"] as! String,
                                     email: userData["email"] as! String,
                                     thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                     normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                     fcmToken: userData["fcmToken"] as? String ?? "")
                                                
                        
                        self.db.collection("users").whereField("uid", in: data["to"] as! [String]).getDocuments{ (querySnapshot, error) in
                            guard let querySnapshot = querySnapshot else {
                                print("Error retrieving all users documents: \(String(describing: error?.localizedDescription))")
                                return
                            }
                            
                            var to = [MealqUser: String]()
                            
                            for document in querySnapshot.documents {
                                let userData = document.data()
                                to[MealqUser(id: document.documentID,
                                             fullname: userData["fullname"] as! String,
                                             email: userData["email"] as! String,
                                             thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                             normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                             fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[document.documentID]
                            }
                            
                            let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue())
                            
                           
                            if status == "pending" {
                                for idx in self.pendingMeals.indices {
                                    if self.pendingMeals[idx] == meal {
                                        self.pendingMeals[idx] = meal
                                    }
                                }
                                
                            }
                            else if status == "accepted" {
                                for idx in self.acceptedMeals.indices {
                                    if self.acceptedMeals[idx] == meal {
                                        self.acceptedMeals[idx] = meal
                                    }
                                }
                            }
                        }
                        

                    } else {
                        print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                    }
                }
                
            } else {
                print("The document for meal \(docID) does not exist")
            }
        }
    }
    
    
    /// Construct a `Meal` model and append it to the designated array.
    ///
    /// - parameter docID: the id of the meal.
    /// - parameter status: the array to append the `Meal`.
    private func addMeal(_ docID: String, by status: String)  {
        
        // get the specific chat from docID
        db.collection("chats").document(docID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()!
                let name = data["name"] as! String
                let id = data["mealID"] as! String
                let from = data["from"] as! String
                let weekday = data["weekday"] as! Int
                let userStatus = data["userStatus"] as! [String: String]
                let createdAt = data["createdAt"] as! Timestamp
                
                // fetch user detail info
                self.db.collection("users").document(from).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let userData = document.data()!
                        let fromUser = MealqUser(id: from,
                                     fullname: userData["fullname"] as! String,
                                     email: userData["email"] as! String,
                                     thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                     normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                     fcmToken: userData["fcmToken"] as? String ?? "")
                                                
                        
                        self.db.collection("users").whereField("uid", in: data["to"] as! [String]).getDocuments{ (querySnapshot, error) in
                            guard let querySnapshot = querySnapshot else {
                                print("Error retrieving all users documents: \(String(describing: error?.localizedDescription))")
                                return
                            }
                            
                            var to = [MealqUser: String]()
                            
                            for document in querySnapshot.documents {
                                let userData = document.data()
                                to[MealqUser(id: document.documentID,
                                             fullname: userData["fullname"] as! String,
                                             email: userData["email"] as! String,
                                             thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                             normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                             fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[document.documentID]
                            }
                            
                            let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue())
                            
                           
                            if status == "pending" { self.pendingMeals.append(meal)}
                            else if status == "accepted" { self.acceptedMeals.append(meal) }
                        
                        }
                        
                        
                        
//                        for userID in data["to"] as! [String]  {
//
//
//
//
//                            self.db.collection("users").document(userID).getDocument{ (document, error) in
//                                if let document = document, document.exists {
//                                    let userData = document.data()!
//                                    self.to[MealqUser(id: userID,
//                                                 fullname: userData["fullname"] as! String,
//                                                 email: userData["email"] as! String,
//                                                 thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
//                                                 normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
//                                                 fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[userID]
//
//
//                                } else {
//                                    print("The document for user \(userID) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
//                                }
//                            }
//                        }
                        

                        
                    } else {
                        print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                    }
                }
                

                


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
        
        if let _ = user  {
            
            
            let newMeal = self.db.collection("chats").document()
            
            let payload = ["mealID": newMeal.documentID,
                           "from": me.id,
                           "to": users.map{$0.id},
                           "name": mealName.isEmpty ? "a meal" : mealName,
                           "userStatus": users.reduce(into: [String: String]()){$0[$1.id] = "pending"},
                           "weekday": weekday ?? 0,
                           "createdAt": Date()
            ] as [String : Any]
            
            
            newMeal.setData(payload) {err in
                if let err = err {
                    self.sendingMealRequest = .error //DEBUG: Change it to .done for debugging purpose
                    print("Something went wrong when sending meal request: \(err.localizedDescription)")
                    return
                } else {
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
                    self.sendingMealRequest = .done // REMEMBER TO MOVE IT TO MESSAGING
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
    
    
    @Published var acceptingMeal = Status.idle
    func updateMealStatus(to status: String, of mealID: String) {
        acceptingMeal = .loading
        
        if let currentUser = user {
            // change user meal status to accepted
            self.db.collection("users").document(currentUser.uid).collection("meals").document(mealID).updateData(["status": status]) {err in
                if let err = err {
                    print("Error updating user \(currentUser.uid)'s meal status to \(status)\(err.localizedDescription)")
                    self.acceptingMeal = .error
                } else {
                    print("Successfully updated user \(currentUser.uid)'s meal status to \(status)!")
                    
                    self.db.collection("chats").document(mealID).updateData([
                        "userStatus.\(currentUser.uid)": status
                    ]) {err in
                        if let err = err {
                            print("Error updating meal \(mealID)'s userStatus for \(currentUser.uid) status to \(status)\(err.localizedDescription)")
                            self.acceptingMeal = .error
                        } else {
                            self.acceptingMeal = .done
                            print("Successfully updated meal \(mealID)'s userStatus for \(currentUser.uid) meal status to \(status)!")
                        }
                    }
                }
            }
            
            
            
            
        }
        
        
        
        
    }
    
    
    
    enum Status {
        case idle, loading, done, error
    }
    
    
}
