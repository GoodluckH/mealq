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
import CoreLocation


/// A manager to handle fething group chat (meal) requests, sending messages, updating friends activities, etc.
class MealsManager: ObservableObject {
    private var db = Firestore.firestore()
   // private let user = Auth.auth().currentUser

    @Published var pendingMeals = [NotificationItem]()
    
    @Published var acceptedMeals = [Meal]()
        
    // @Published var rejectedMeals = [Meal]()
    
    /// Fetches meals from the current user's "meals" collection;
    /// If the status on the database shows "pending", then construct a `Meal` model and append it to `pendingMeals`;  similarly for "accepted" meals
    ///
    /// - SeeAlso: `Meal`, `pendingMeals`, `acceptedMeals`, `addMeal`
    func fetchMeals() {
        if let currentUser =  Auth.auth().currentUser {

            self.db.collection("chats").whereField("to", arrayContains: currentUser.uid).addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("failed to retrieve meals snapshot")
                    return
                }
                
                snapshot.documentChanges.forEach {diff in
                    
                    // NEWLY ADDED MEALS
                    if (diff.type == .added) {
                        let data = diff.document.data()
                        let status = data["userStatus"] as! [String: String]
                        self.addMeal(diff.document.documentID, by: status[currentUser.uid]!, user: currentUser)
                    }
                    
                    // MEAL INFO CHANGED
                    if (diff.type == .modified) {
                        let data = diff.document.data()
                        let status = data["userStatus"] as! [String: String]
                        let mealID = data["mealID"] as! String
                        
                        if status[currentUser.uid]! == "pending" {
                            self.modifyMeal(diff.document.documentID, by: status[currentUser.uid]!, user: currentUser)
                        }

                        if status[currentUser.uid]! == "accepted" {
                            if let idx = self.pendingMeals.firstIndex(where: {($0.payload as! Meal).id == mealID}) {
                                self.pendingMeals.remove(at: idx)
                                self.addMeal(diff.document.documentID, by: status[currentUser.uid]!, user: currentUser)
                            } else {
                                self.modifyMeal(diff.document.documentID, by: status[currentUser.uid]!, user: currentUser)
                            }
                        }
                        
                        if status[currentUser.uid]! == "declined" {
                            if let idx = self.pendingMeals.firstIndex(where: {($0.payload as! Meal).id == mealID}) {
                                self.pendingMeals.remove(at: idx)
                            }
                            if let idx = self.acceptedMeals.firstIndex(where: {$0.id == mealID}) {
                                self.acceptedMeals.remove(at: idx)
                            }
                        }
                        
                        // TODO: add the logic for rejected meals
                    }
                    
                    if (diff.type == .removed) {
                        let data = diff.document.data()
                        let mealID  = data["mealID"] as! String
                        
                        self.pendingMeals = self.pendingMeals.filter{($0.payload as! Meal).id != mealID}
                        self.acceptedMeals = self.acceptedMeals.filter{$0.id != mealID}
                        self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                    }
                    
                    
                }
                
            }
            
            self.db.collection("chats").whereField("from", isEqualTo: currentUser.uid).addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("failed to retrieve meals snapshot")
                    return
                }
                
                snapshot.documentChanges.forEach {diff in
                    if (diff.type == .added) {
                        self.addMeal(diff.document.documentID, by: "accepted", user: currentUser)
                    }
                    if (diff.type == .modified) {
                        self.modifyMeal(diff.document.documentID, by: "accepted", user: currentUser)
                        // TODO: add the logic for rejected meals
                    }
                }
            
            }
        }
    }
    

    
    private func modifyMeal(_ docID: String, by status: String, user: User) {
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
                
                let recentMessage = data["recentMessage"] as? [String: Any] ?? [:]
                let unreadMessagesMap = data["unreadMessages"] as? [String: Any] ?? [:]
                
                let recentMessageContent = recentMessage["content"] as? String ?? ""
                let sentByName = recentMessage["sentByName"] as? String ?? ""
                let messageTimeStamp = recentMessage["timeStamp"] as? Timestamp ?? createdAt
//                let isMessageViewed = data["recentMessage.viewed"] as? Bool ?? true
                let recentMessageID = recentMessage["messageID"] as? String ?? ""
                
                let unreadMessages = unreadMessagesMap[user.uid] as? Int ?? 0
                
                let specificDate = data["specificDate"] as? Timestamp ?? nil
                
                let place = data["location"] as? GeoPoint ?? nil
                var placemark: CLPlacemark? = nil
                if let place = place {
                    let location = CLLocation(latitude: place.latitude, longitude: place.longitude)
                    let coder = CLGeocoder()
                    coder.reverseGeocodeLocation(location) {placemarks, error in
                        if let error = error {
                            print("failed to parse placemarks: \(error)")
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
                                        
                                        let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue())
                                        
                                       
                                        if status == "pending" {
                                            for idx in self.pendingMeals.indices {
                                                if self.pendingMeals[idx].payload as! Meal == meal {
                                                    let oldID = self.pendingMeals[idx].id
                                                    let oldTimeStamp = self.pendingMeals[idx].timeStamp
                                                    self.pendingMeals[idx] = NotificationItem(id: oldID, payload: meal, timeStamp: oldTimeStamp)
                                                }
                                            }
                                            
                                            
                                        }
                                        else if status == "accepted" {
                                            for idx in self.acceptedMeals.indices {
                                                if self.acceptedMeals[idx] == meal {
                                                    self.acceptedMeals[idx] = meal
                                                }
                                            }
                                            self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                        }
                                    }
                                    

                                } else {
                                    print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        } else {
                            placemark = placemarks?.last
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
                                        
                                        let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue(), place: placemark == nil ? nil : Place(placemark: placemark!))
                                        
                                       
                                        if status == "pending" {
                                            for idx in self.pendingMeals.indices {
                                                if self.pendingMeals[idx].payload as! Meal == meal {
                                                    let oldID = self.pendingMeals[idx].id
                                                    let oldTimeStamp = self.pendingMeals[idx].timeStamp
                                                    self.pendingMeals[idx] = NotificationItem(id: oldID, payload: meal, timeStamp: oldTimeStamp)
                                                }
                                            }
                                            
                                            
                                        }
                                        else if status == "accepted" {
                                            for idx in self.acceptedMeals.indices {
                                                if self.acceptedMeals[idx] == meal {
                                                    self.acceptedMeals[idx] = meal
                                                }
                                            }
                                            self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                        }
                                    }
                                    

                                } else {
                                    print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        }
                    }
                } else {
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
                                
                                let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue())
                                
                               
                                if status == "pending" {
                                    for idx in self.pendingMeals.indices {
                                        if self.pendingMeals[idx].payload as! Meal == meal {
                                            let oldID = self.pendingMeals[idx].id
                                            let oldTimeStamp = self.pendingMeals[idx].timeStamp
                                            self.pendingMeals[idx] = NotificationItem(id: oldID, payload: meal, timeStamp: oldTimeStamp)
                                        }
                                    }
                                    
                                    
                                }
                                else if status == "accepted" {
                                    for idx in self.acceptedMeals.indices {
                                        if self.acceptedMeals[idx] == meal {
                                            self.acceptedMeals[idx] = meal
                                        }
                                    }
                                    self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                }
                            }
                            

                        } else {
                            print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                        }
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
    private func addMeal(_ docID: String, by status: String, user: User)  {
        
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
                
                let recentMessage = data["recentMessage"] as? [String: Any] ?? [:]
                let unreadMessagesMap = data["unreadMessages"] as? [String: Any] ?? [:]
                
                let recentMessageContent = recentMessage["content"] as? String ?? ""
                let sentByName = recentMessage["sentByName"] as? String ?? ""
                let messageTimeStamp = recentMessage["timeStamp"] as? Timestamp ?? createdAt
                let recentMessageID = recentMessage["messageID"] as? String ?? ""
                
                let unreadMessages = unreadMessagesMap[user.uid] as? Int ?? 0
                
                let specificDate = data["specificDate"] as? Timestamp ?? nil
                
                let place = data["location"] as? GeoPoint ?? nil
                var placemark: CLPlacemark? = nil
                
                if let place = place {
                    let location = CLLocation(latitude: place.latitude, longitude: place.longitude)
                    let coder = CLGeocoder()
                    coder.reverseGeocodeLocation(location) {placemarks, error in
                        if let error = error {
                            print("failed to parse placemarks: \(error)")
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
                                        
                                        let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue())
                                        
                                       
                                        if status == "pending" { self.pendingMeals.append(NotificationItem(id: UUID(), payload: meal, timeStamp: meal.createdAt))}
                                        else if status == "accepted" {
                                            self.acceptedMeals.append(meal)
                                            self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                        }
                                    }
                                    

                                } else {
                                    print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        } else {
                            placemark = placemarks?.last
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
                                        
                                        let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue(), place: placemark == nil ? nil : Place(placemark: placemark!))
                                       
                                        if status == "pending" { self.pendingMeals.append(NotificationItem(id: UUID(), payload: meal, timeStamp: meal.createdAt))}
                                        else if status == "accepted" {
                                            self.acceptedMeals.append(meal)
                                            self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                        }
                                    }
                                    

                                } else {
                                    print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                                }
                            }
                        }
                    }
                    
                } else {
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
                                
                                let meal = Meal(id: id, name: name, from: fromUser, to: to, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: recentMessageID, recentMessageContent: recentMessageContent, sentByName: sentByName, messageTimeStamp: messageTimeStamp.dateValue(), unreadMessages: unreadMessages, specificDate: specificDate?.dateValue())
                                
                               
                                if status == "pending" { self.pendingMeals.append(NotificationItem(id: UUID(), payload: meal, timeStamp: meal.createdAt))}
                                else if status == "accepted" {
                                    self.acceptedMeals.append(meal)
                                    self.acceptedMeals.sort(by: {$0.messageTimeStamp.compare($1.messageTimeStamp) == .orderedDescending})
                                }
                            
                            }


                            
                        } else {
                            print("The document for user \(from) does not exist when retrieving such user's data to construct the Meal data model: \(String(describing: error?.localizedDescription))")
                        }
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
        
        if let _ =  Auth.auth().currentUser  {
            
            let newMeal = self.db.collection("chats").document()
            let date = Date()
            let payload = ["mealID": newMeal.documentID,
                           "from": me.id,
                           "to": users.map{$0.id},
                           "name": mealName.isEmpty ? Constants.defaultMealName : mealName,
                           "userStatus": users.reduce(into: [String: String]()){$0[$1.id] = "pending"},
                           "weekday": weekday ?? 0,
                           "createdAt": date,
                           "recentMessage": ["content": "", "sentByName": "", "timeStamp": date],
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
            batch.setData(["status": "accepted"], forDocument: self.db.collection("users").document(me.id).collection("meals").document(newMeal.documentID))
            batch.updateData([
                "createdMeals": FieldValue.arrayUnion([["createdAt": date, "mealID": newMeal.documentID]])
            ], forDocument: self.db.collection("users").document(me.id))
            
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    self.sendingMealRequest = .done // REMEMBER TO MOVE IT TO MESSAGING
                    print("Batch write succeeded.")
                    FriendsManager.sharedFriendsManager.selectedFriends = []
                }
            }
            
            
            
        } else {
            print("Could not fetch current user when sending meal request")
            self.sendingMealRequest = .error
        }
    }
    
    
    @Published var acceptingMeal = Status.idle
    func updateMealStatus(to status: String, of mealID: String) {
        acceptingMeal = .loading
        
        if let currentUser = Auth.auth().currentUser {
            // change user meal status to accepted
            self.db.collection("users").document(currentUser.uid).collection("meals").document(mealID).updateData(["status": status]) {err in
                if let err = err {
                    print("Error updating user \(currentUser.uid)'s meal status to \(status)\(err.localizedDescription)")
                    self.acceptingMeal = .error
                } else {
                    print("Successfully updated user \(currentUser.uid)'s meal status to \(status)!")
                    
                    
                    
                    var payload: [String: Any] = ["userStatus.\(currentUser.uid)": status]
                    if (status == "accepted") {
                        payload["recentMessage.content"] = "\(currentUser.displayName!) has joined the chat!"
                        payload["recentMessage.timeStamp"] = Date()
                    }
                    
                    self.db.collection("chats").document(mealID).updateData(payload) {err in
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
    
    
    
    func setMessageAsViewed(mealID: String, count: Int) {
        if let user =  Auth.auth().currentUser {
            self.db.collection("chats").document(mealID).updateData([
                "unreadMessages.\(user.uid)": FieldValue.increment(Int64(-count))
            ]) { err in
                if let err = err {
                    print("Unable to set message's read status: \(err.localizedDescription)")
                } else {
                    print("Successfully set message as read")
                }
                
            }
        }
    }
    
    
    @Published var changingMealName = Status.idle
    func changeMealName(to newName: String, for mealID: String) {
        
        if let currentUser =  Auth.auth().currentUser {
            changingMealName = .loading
            db.collection("chats").document(mealID).updateData([
                "name": newName]) { err in
                    if let err = err {
                        self.changingMealName = .error
                        print("error changing meal name: \(err.localizedDescription)")
                    } else {
                        let message =  self.db.collection("chats").document(mealID).collection("messages").document()
                        let payload = [
                            "id": message.documentID,
                            "senderID": "SYSTEM",
                            "senderName": "SYSTEM",
                            "content":  "\(currentUser.displayName!) changed the group chat name to \"\(newName)\"",
                            "timeStamp": Date()
                        ] as [String: Any]
                        message.setData(payload) { err in
                            if let err = err {
                                print("something went wrong when setting the system message to reflect the meal name change: \(err.localizedDescription)")
                                self.changingMealName = .error
                                return
                            } else {
                                print("successfully set the system message to reflect the meal name change")
                                print("successfully changed meal name to \(newName)")
                                self.changingMealName = .idle

                            }
                        }
                        
                    }
                    
                }
        }
     
    }
    
    
    @Published var settingSpecificDate = Status.idle
    func setSpecificDate(on date: Date, for mealID: String) {
        if let currentUser = Auth.auth().currentUser {
            settingSpecificDate = .loading
            db.collection("chats").document(mealID).updateData([
                "specificDate": date,
                "weekday": (Calendar.current.component(.weekday, from: date) - 1) == 0 ? 7 : (Calendar.current.component(.weekday, from: date) - 1)
            ]) { err in
                    if let err = err {
                        self.settingSpecificDate = .error
                        print("error setting specific date: \(err.localizedDescription)")
                    } else {
                        let message =  self.db.collection("chats").document(mealID).collection("messages").document()
                        let payload = [
                            "id": message.documentID,
                            "senderID": "SYSTEM",
                            "senderName": "SYSTEM",
                            "content":  "\(currentUser.displayName!) modified the date",
                            "timeStamp": Date()
                        ] as [String: Any]
                        message.setData(payload) { err in
                            if let err = err {
                                print("something went wrong when setting the system message to reflect the meal name change: \(err.localizedDescription)")
                                self.changingMealName = .error
                                return
                            } else {
                                self.settingSpecificDate = .idle
                                print("successfully set date for meal \(mealID)")

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


