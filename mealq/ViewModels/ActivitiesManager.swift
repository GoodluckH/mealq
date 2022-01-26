//
//  ActivitiesManager.swift
//  mealq
//
//  Created by Xipu Li on 1/25/22.
//

import Foundation
import Firebase


class ActivitiesManager: ObservableObject {
    
    enum Status {
        case idle, loading, done, error
    }
    
    
    private var db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    /// For pagination purpose.
    private var lastDoc: QueryDocumentSnapshot? = nil
    
    @Published var activities = [Meal]()

    private var masterAcitivityArray = [[String: Any]]()
    private var currentSliceEnd = 0
    
    
    
    @Published var loadingActivities = Status.idle
    func getRecentActivities() {
        if let user = user {
            self.loadingActivities = .loading
            self.db.collection("users").document(user.uid).collection("friends").getDocuments{ snapshots, error in
                guard let documents = snapshots?.documents else {
                    print("getRecentActivities: Error fetching current user's doc: \(error?.localizedDescription ?? "")")
                    self.loadingActivities  = .error
                    return
                }
                
                var friends = [String]()
                friends = documents.map {$0.documentID}
                
                let myGroup = DispatchGroup()
            
                for friend in friends {
                    myGroup.enter()
                    self.db.collection("users").document(friend).getDocument{ doc, error in
                        guard let doc = doc, doc.exists else {
                            print("Error fetching friend \(friend)'s meals: \(error?.localizedDescription ?? "")")
                            self.loadingActivities  = .error
                            return
                        }
                        let data = doc.data()!
                        if let createdMeals = data["createdMeals"] as? [[String: Any]] {
                            print("yes craeted meals for \(friend)")
                            self.masterAcitivityArray.append(contentsOf: createdMeals)
                        } else {
                            print("no created meals for \(friend)")
                        }
                        
                        myGroup.leave()
                    }
                
                }
            
                myGroup.notify(queue: .main) {
                    self.masterAcitivityArray.sort(by: {
                        ($0["createdAt"]! as! Timestamp).dateValue() > ($1["createdAt"]! as! Timestamp).dateValue()
                    })
                    
                    // start getting the first batch of 10 meal docs
                    self.currentSliceEnd = min(10, self.masterAcitivityArray[self.currentSliceEnd...].count)
                    if !self.masterAcitivityArray.isEmpty
                    {
                        print("master is not empty")
                        self.masterAcitivityArray.forEach { act in
                            print((act["createdAt"]! as! Timestamp).dateValue())
                        }
                        self.getMoreActivities()
                        
                    } else {
                        print("master is empty")
                        self.loadingActivities  = .idle
                    }
                }
                
             
                
            }
            
    }
}
    /// Gets ten more meal sections from `masterActivityArray` starting at `id`.
    func getMoreActivities(fromIndex id: Int = 0) {
        db.collection("chats").whereField("mealID", in: masterAcitivityArray[id...].map{$0["mealID"]! as! String}).limit(to: 10).getDocuments {snapshot, error in
            self.loadingActivities  = .loading
            guard let documents = snapshot?.documents else {
                print("Error getting more activities: \(error?.localizedDescription ?? "")")
                self.loadingActivities  = .error
                return
            }

            self.currentSliceEnd = self.currentSliceEnd + documents.count

            let myGroup = DispatchGroup()


            for doc in documents {
                myGroup.enter()
                let data = doc.data()
                let name = data["name"] as! String
                let id = data["mealID"] as! String
                let from = data["from"] as! String
                let weekday = data["weekday"] as! Int
                let userStatus = data["userStatus"] as! [String: String]
                let createdAt = data["createdAt"] as! Timestamp
                let to = data["to"] as! [String]


                self.db.collection("users").document(from).getDocument {(document, error) in
                    if let document = document, document.exists {
                        let userData = document.data()!
                        let fromUser = MealqUser(id: from,
                                     fullname: userData["fullname"] as! String,
                                     email: userData["email"] as! String,
                                     thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                     normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                     fcmToken: userData["fcmToken"] as? String ?? "")

                        self.db.collection("users").whereField("uid", in: to).getDocuments{ (querySnapshot, error) in
                            guard let querySnapshot = querySnapshot else {
                                print("Error retrieving all users documents: \(String(describing: error?.localizedDescription))")
                                self.loadingActivities  = .error
                                return
                            }

                            var toUsers = [MealqUser: String]()

                            for document in querySnapshot.documents {
                                let userData = document.data()
                                toUsers[MealqUser(id: document.documentID,
                                             fullname: userData["fullname"] as! String,
                                             email: userData["email"] as! String,
                                             thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                             normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                             fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[document.documentID]
                            }

                            let meal = Meal(id: id, name: name, from: fromUser, to: toUsers, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: "", recentMessageContent: "", sentByName: "", messageTimeStamp: createdAt.dateValue(), unreadMessages: 0)
                            self.activities.append(meal)
                           
                            myGroup.leave()
                            self.loadingActivities  = .idle
                     }
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                self.activities.sort(by: {$0.createdAt > $1.createdAt})
                self.loadingActivities  = .idle
            }
            






        }

    }
    
    

}
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
//            self.activities.append(contentsOf:
//
//
//            documents.map { doc in
//
//
//                let data = doc.data()
//                let name = data["name"] as! String
//                let id = data["mealID"] as! String
//                let from = data["from"] as! String
//                let weekday = data["weekday"] as! Int
//                let userStatus = data["userStatus"] as! [String: String]
//                let createdAt = data["createdAt"] as! Timestamp
//                let to = data["to"] as! [String]
//
//                var toUsers = [MealqUser: String]()
//                var fromUser: MealqUser?
//
//                self.db.collection("users").document(from).getDocument {(document, error) in
//                    if let document = document, document.exists {
//                        let userData = document.data()!
//                        fromUser = MealqUser(id: from,
//                                     fullname: userData["fullname"] as! String,
//                                     email: userData["email"] as! String,
//                                     thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
//                                     normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
//                                     fcmToken: userData["fcmToken"] as? String ?? "")
//
//                        for userID in to {
//                            myGroup.enter()
//                            self.db.collection("users").document(userID).getDocument{ (document, error) in
//                                if let document = document, document.exists {
//                                    let userData = document.data()!
//                                    toUsers[MealqUser(id: from,
//                                                 fullname: userData["fullname"] as! String,
//                                                 email: userData["email"] as! String,
//                                                 thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
//                                                 normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
//                                                 fcmToken: userData["fcmToken"] as? String ?? "")] = userStatus[userID]!
//                                }
//                                myGroup.leave()
//                            }
//                        }
//
//
//
//                    }
//
//                }
//
//
//                myGroup.notify(queue: .main) {
//                    let meal =  Meal(id: id, name: name, from: fromUser!, to: toUsers, weekday: weekday, createdAt: createdAt.dateValue(), recentMessageID: "", recentMessageContent: "", sentByName: "", messageTimeStamp: createdAt.dateValue(), unreadMessages: 0)
//                    return meal
//                }
//
//
//            })
            
            


