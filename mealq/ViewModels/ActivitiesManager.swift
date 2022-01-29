//
//  ActivitiesManager.swift
//  mealq
//
//  Created by Xipu Li on 1/25/22.
//

import Foundation
import Firebase
import Combine


class ActivitiesManager: ObservableObject {
    
    enum Status {
        case idle, loading, done, error
    }
    
    
    private var db = Firestore.firestore()
    private var friendsManager = FriendsManager.sharedFriendsManager
    private let user = Auth.auth().currentUser
    
    /// For pagination purpose.
    private var lastDoc: QueryDocumentSnapshot? = nil
    
    @Published var activities = [Meal]()
    @Published var masterAcitivityArray = [[String: Any]]()
    @Published var currentSliceEnd = 0
    
    private var isListeningForNewActivities = false
    private var isFirstTimeListening = true
    
    func listenForNewActivities() {
        if let user = user {
            // Listen for modifications in the user collection
            // Check what is being modified

            self.db.collection("chats").addSnapshotListener{ (querySnapshot, error) in
                guard let snapshotMain = querySnapshot else {
                    print("failed to retrieve meals snapshot")
                    return
                }
                let myGroup = DispatchGroup()
                
                print("triggered!")
              
                    snapshotMain.documentChanges.forEach {diff in
                        myGroup.enter()
                        // NEWLY ADDED MEALS
                        if (diff.type == .added) {
                            print("yes it is added!")
                            if !self.isFirstTimeListening {
                                print("not the first time listening")
                            let data = diff.document.data()
                            let from = data["from"] as! String
                            
                                if from == user.uid || (self.friendsManager.friends.map{$0.id}.firstIndex(of: from) != nil) {
                                        let name = data["name"] as! String
                                        let id = data["mealID"] as! String
                                        let weekday = data["weekday"] as! Int
                                        let userStatus = data["userStatus"] as! [String: String]
                                        let createdAt = data["createdAt"] as! Timestamp
                                        let to = data["to"] as! [String]
                                        print("New meal found!")
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

                                                    let meal = Meal(id: id,
                                                                    name: name,
                                                                    from: fromUser,
                                                                    to: toUsers,
                                                                    weekday: weekday,
                                                                    createdAt: createdAt.dateValue(),
                                                                    recentMessageID: "",
                                                                    recentMessageContent: "",
                                                                    sentByName: "",
                                                                    messageTimeStamp: createdAt.dateValue(),
                                                                    unreadMessages: 0)
                                                    self.activities.insert(meal, at: 0)
                                                   
                                                    myGroup.leave()
                                                   
                                             }
                                            }
                                        }
                                        
                                    } else {myGroup.leave()}
                                
                                
                                
                                
                            
                            } else {myGroup.leave()}
                            
                        } else {myGroup.leave()}
      
                }
            
                myGroup.notify(queue: .main) {
                    if self.isFirstTimeListening {
                        print("it's first time listening, do nothing")
                        self.isFirstTimeListening = false
                    }
                }
                
            }
        }
        
    }


    private var cancellable : AnyCancellable?
    @Published var loadingActivities = Status.loading
    func getRecentActivities() {
        if let user = user {
            self.loadingActivities = .loading
            self.cancellable = self.friendsManager.$fetchingFriends.sink { value in
                guard value == .idle else {return}
                
                
                let myGroup = DispatchGroup()
            
                var friendIDs: [String] = self.friendsManager.friends.map{$0.id}
                friendIDs.append(user.uid)
                for friend in friendIDs {
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
                   // self.currentSliceEnd = min(10, self.masterAcitivityArray[self.currentSliceEnd...].count)
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
        else {
            print("loadingActivities - current user not available")
            self.loadingActivities = .idle
        }
}
    /// Gets ten more meal sections from `masterActivityArray` starting at `id`.
    func getMoreActivities(fromIndex id: Int = 0, delay: Bool = false) {
        if id > (self.masterAcitivityArray.count - 1) {return;}
        let endIndex = min(id + 10, masterAcitivityArray.count)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 0.2 : 0)){
            self.db.collection("chats").whereField("mealID", in: self.masterAcitivityArray[id..<endIndex].map{$0["mealID"]! as! String}).getDocuments {snapshot, error in
            if !delay {self.loadingActivities  = .loading}
            guard let documents = snapshot?.documents else {
                print("Error getting more activities: \(error?.localizedDescription ?? "")")
                self.loadingActivities  = .error
                return
            }

            self.currentSliceEnd = self.currentSliceEnd + documents.count

            let myGroup = DispatchGroup()
            
            // To prevent UI sort ordering in run-time
            var tempActivities = [Meal]()
            
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

                print(name)
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

                            let meal = Meal(id: id,
                                            name: name,
                                            from: fromUser,
                                            to: toUsers,
                                            weekday: weekday,
                                            createdAt: createdAt.dateValue(),
                                            recentMessageID: "",
                                            recentMessageContent: "",
                                            sentByName: "",
                                            messageTimeStamp: createdAt.dateValue(),
                                            unreadMessages: 0)
                            
                            
                            tempActivities.append(meal)
                           
                            myGroup.leave()
                            // self.loadingActivities  = .idle
                     }
                    }
                }
            }
            
            myGroup.notify(queue: .main) {
                tempActivities.sort(by: {$0.createdAt > $1.createdAt})
                self.activities.append(contentsOf: tempActivities)
                self.loadingActivities = .idle
                if !self.isListeningForNewActivities {
                    self.listenForNewActivities()
                    self.isListeningForNewActivities = true
                }
            }
            






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
            
            


