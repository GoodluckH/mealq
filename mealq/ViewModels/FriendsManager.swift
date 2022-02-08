//
//  FriendsManager.swift
//  mealq
//
//  Created by Xipu Li on 11/2/21.
//

import Foundation
import Firebase
import FirebaseAuth


class MiniFriendsManager: ObservableObject {
    private let db = Firestore.firestore()
    private var currentUser = Auth.auth().currentUser
    @Published var queriedFriends = false
    @Published var friendsOfQueriedUser = [MealqUser]()
    
    func getFriendsFrom(_ userID: String) {
        db.collection("users").document(userID).collection("friends").getDocuments() { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print ("cannot get data from user \(userID)")
                return
            }
            let userIDs = documents.map { $0.documentID }
            
            let myGroup = DispatchGroup()
            
            userIDs.forEach{ id in
                myGroup.enter()
                self.db.collection("users").document(id).getDocument { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print ("User \(id) does not exist on db")
                        return
                    }
                    let userData = snapshot.data()!
                    self.friendsOfQueriedUser.append(MealqUser(id:  userData["uid"] as! String,
                                                               fullname: userData["fullname"] as! String,
                                                               email: userData["email"] as! String,
                                                               thumbnailPicURL: URL(string: userData["thumbnailPicURL"] as? String ?? ""),
                                                               normalPicURL: URL(string: userData["normalPicURL"] as? String ?? ""),
                                                               fcmToken: userData["fcmToken"] as? String ?? ""))
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {self.queriedFriends = true}
        }
    }
}



enum Status {
    case idle, loading, done, error
}

/// A ViewModel that manages operations involving fetching and querying other users and friends.
class FriendsManager: ObservableObject {
    
    
    static let sharedFriendsManager = FriendsManager()
    
    private init() {}
    
    private let db = Firestore.firestore()
   //  private var currentUser = Auth.auth().currentUser
    
    
    @Published var friends = [MealqUser]()
    @Published var pendingFriends = [NotificationItem]()
    @Published var sentRequests = [MealqUser]()
    
    @Published var selectedFriends = [MealqUser]()
    @Published var changedFriendSelection = false

    @Published var fetchingFriends = Status.loading
    /// Fetches a list of the current user's friends and updates `friends`.
    ///
    /// Uses Firestore's snapshot listener to only fetch and update new changes.
    ///  - SeeAlso: `friends`.
    func fetchData() {
        if let currentUser = Auth.auth().currentUser { // Synchronously get current user should be fine here because fetchData is only used when there's a valid user (see MainAppView)
           
            // update the friends list
            db.collection("users").document(currentUser.uid).collection("friends").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("no friends :(  --- failed to retrieve snapshot")
                    self.fetchingFriends = .error
                    return
                }
                print("fetching friends")
                self.friends = documents.map { docSnapshot in
                    let data = docSnapshot.data()
                    let FirebaseID = data["uid"] as! String
                    let fullName = data["fullname"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                    let normalPicURL = data["normalPicURL"] as? String ?? ""
                    let fcmToken  = data["fcmToken"] as? String ?? ""
                    return MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL), fcmToken: fcmToken)
                }
                
                self.fetchingFriends = .idle
            }
            
            
            // update to see if there's any friend requests
            db.collection("users").document(currentUser.uid).collection("requests").addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends requests :(  --- failed to retrieve snapshot")
                    return
                }
                
                self.pendingFriends = documents.map { docSnapshot in
                    let data = docSnapshot.data()
                    let FirebaseID = data["uid"] as! String
                    let fullName = data["fullname"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                    let normalPicURL = data["normalPicURL"] as? String ?? ""
                    let fcmToken  = data["fcmToken"] as? String ?? ""
                    let createdAt = data["createdAt"] as! Timestamp
                    return NotificationItem(id: UUID(), payload: MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL), fcmToken: fcmToken), timeStamp: createdAt.dateValue())
                }
                
//                for docSnapshot in documents {
//                    let data = docSnapshot.data()
//                    let FirebaseID = data["uid"] as! String
//                    let fullName = data["fullname"] as! String
//                    let email = data["email"] as! String
//                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
//                    let normalPicURL = data["normalPicURL"] as? String ?? ""
//                    let fcmToken  = data["fcmToken"] as? String ?? ""
//                    let createdAt = data["createdAt"] as! Timestamp
//                    self.pendingFriends[MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL), fcmToken: fcmToken)] = createdAt.dateValue()
//                }
//                self.pendingFriends = documents.map { docSnapshot in
//                    let data = docSnapshot.data()
//                    let FirebaseID = data["uid"] as! String
//                    let fullName = data["fullname"] as! String
//                    let email = data["email"] as! String
//                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
//                    let normalPicURL = data["normalPicURL"] as? String ?? ""
//                    let fcmToken  = data["fcmToken"] as? String ?? ""
//                    let createdAt = data["createdAt"] as! Date
//                    print(createdAt)
//                    return
//                }
     
            }
            
            
            // update the sent requets
            db.collection("users").document(currentUser.uid).collection("sentRequests").addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends requests :(  --- failed to retrieve snapshot")
                    return
                }
                
                self.sentRequests = documents.map { docSnapshot in
                    let data = docSnapshot.data()
                    let FirebaseID = data["uid"] as! String
                    let fullName = data["fullname"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                    let normalPicURL = data["normalPicURL"] as? String ?? ""
                    let fcmToken  = data["fcmToken"] as? String ?? ""
                    return MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL), fcmToken: fcmToken)
                }
            }
        } else {
            print("Cannot fetch current Firebase user.")
            fetchingFriends = .error
        }

    }
    
    

    /// A flag to indicate whether query results from a previous async request should be stored.
    private var stopQuery = false
    @Published var resolvingQuery = true
    @Published var queryResult = ["friends": [MealqUser](), "others": [MealqUser]()]

    /// Filters the current user's friends and all other users based on query string.
    ///
    /// Performs filtering on the existing `friends` array first to optimize for user experience. The `friends` array should already been updated because `fetchData` is called before any query.
    ///
    /// - parameter text: the query string used for filtering.
    func queryString(of text: String, currentUserId: String) {
        if text.isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty {
            queryResult = ["friends": [MealqUser](), "others": [MealqUser]()]
            stopQuery = true
            return
        }
        self.resolvingQuery = true
        
        // Filters friends based on query string.
        self.queryResult["friends"]! = self.friends.filter {$0.fullname.lowercased().contains(text.lowercased())}
    
        self.stopQuery = false
        
        
        // Filters all other users.
        //if let currentUser = Auth.auth().currentUser {
        self.db.collection("users").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                self.resolvingQuery = false
                print("Couldn't fetch documents")
                return
            }
            
        
            var othersResult = [MealqUser]()
            for document in documents {
                if  !self.friends.contains(where:{$0.id == document.documentID})
                    && document.documentID != currentUserId
                    && !self.stopQuery {
                    let docData = document.data()
                    let fullName = docData["fullname"] as! String
                    if fullName.lowercased().contains(text.lowercased()) {
                        let FirebaseID = docData["uid"] as! String
                        let email = docData["email"] as! String
                        let thumbnailPicURL = docData["thumbnailPicURL"] as? String ?? ""
                        let normalPicURL = docData["normalPicURL"] as? String ?? ""
                        let fcmToken = docData["fcmToken"] as? String ?? ""
                        othersResult.append(MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL), fcmToken: fcmToken))
                    }
                }
            }
            self.queryResult["others"]! = othersResult
            self.resolvingQuery = false
            }
           // }
        }
    
    
    /// An array of user uids.
    /// Use this variable to store friends of the other user of choice.
    ///
    /// - SeeAlso: `getFriendsFrom`
    @Published var otherUserFriends = [String]()
    
    /// Fetches friends given a user's id and stores the result to `otherUserFriends`.
    ///
    /// - parameter id: the uid of a user.
    /// - SeeAlso: `otherUserFriends`.
    func getFriendsFrom(user id: String) {
        self.otherUserFriends = [String]()
        db.collection("users").document(id).collection("friends").getDocuments() { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print ("cannot get data from user \(id)")
                return
            }
            self.otherUserFriends = documents.map { $0.documentID }
        }
    }

    
    
    
    // -MARK: Friends Management
    
    
    
    
    @Published var sendingRequest = false
    /// Sends a friend request to the other user.
    ///
    /// Two writes to the database; one is to add the current user to the other user's "requests" collection, the other is to add the other user to the current user's "sentRequests" collection.
    ///
    /// - parameter theOtherUser: the User model of the other user to send the friend request to.
    func sendFriendRequest(to theOtherUser: MealqUser) {
        if let currentUserId = Auth.auth().currentUser?.uid  {
            self.sendingRequest = true
            db.collection("users").document(currentUserId).getDocument() {snapshot, error in
                guard let data = snapshot?.data() else {
                    self.sendingRequest = false
                    print ("cannot get data from user \(currentUserId)")
                    return
                }
                let curFullname = data["fullname"] as! String
                let curFcmToken = data["fcmToken"] as! String
                let curUid = data["uid"] as! String
                let curThumbnailPicURL = data["thumbnailPicURL"] as? String
                let curNormalPicURL = data["normalPicURL"] as? String
                let curEmail = data["email"] as! String
                
                self.db.collection("users").document(theOtherUser.id).collection("requests").document(currentUserId).setData( [
                    "fullname": curFullname,
                    "fcmToken": curFcmToken,
                    "email": curEmail,
                    "uid": curUid,
                    "createdAt": Date(),
                    "thumbnailPicURL": curThumbnailPicURL ?? Constants.placeholder_pic,
                    "normalPicURL": curNormalPicURL ?? Constants.placeholder_pic
                ]) { err in
                    if let err = err {
                        self.sendingRequest = false
                        print("Error adding document: \(err)")
                    } else {
                        print("Friend request succesfully added to: \(theOtherUser.id)")
                    }
                }
                
                
                self.db.collection("users").document(theOtherUser.id).getDocument() {snapshot, error in
                    guard let data = snapshot?.data() else {
                        self.sendingRequest = false
                        print ("cannot get data from user \(currentUserId)")
                        return
                    }
                    
                    let fullname = data["fullname"] as! String
                    let fcmToken = data["fcmToken"] as! String
                    let uid = data["uid"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String
                    let normalPicURL = data["normalPicURL"] as? String
                    
                    self.db.collection("users").document(currentUserId).collection("sentRequests").document(theOtherUser.id).setData([
                        "fullname": fullname,
                        "fcmToken": fcmToken,
                        "email": email,
                        "uid": uid,
                        "createdAt": FieldValue.serverTimestamp(),
                        "thumbnailPicURL": thumbnailPicURL ?? Constants.placeholder_pic,
                        "normalPicURL": normalPicURL ?? Constants.placeholder_pic,
                        // these should show the current user's info so that notification works logically
                        "from": curFullname,
                        "fromThumbnailPicURL": curThumbnailPicURL ?? Constants.placeholder_pic,
                        "fromNormalPicURL": curNormalPicURL ?? Constants.placeholder_pic
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            self.sendingRequest = false
                            print("Sent request added to current users's sentRequests collection")
                        }
                    }
                }        
            }
        }
    }
    
    
    
    
    /// Allows user to retract a sent friend request by removing the other user's doc ref from current user's "sentRequests" collection and by removing current user's doc ref from the other user's "requests" collection.
    /// - parameter otherUserID: the string representation of a user's uid.
    func unsendFriendRequest(to otherUserID: String) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            db.collection("users").document(currentUserId).collection("sentRequests").document(otherUserID).delete() { err in
                if let err = err {
                    print("Error removing sent request: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            db.collection("users").document(otherUserID).collection("requests").document(currentUserId).delete() {err in
                if let err = err {
                    print("Error removing friend request: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
  }
    

    
    /// Declines a friend request by removing the other user from current user's "requests" collection and by removing the current user from the other user's "sentRequests" collections.
    /// - parameter otherUserID: the string representation of a user's uid.
    func declineFriendRequest(from otherUserID: String) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            db.collection("users").document(currentUserId).collection("requests").document(otherUserID).delete() { err in
                if let err = err {
                    print("Error declining friend request: \(err)")
                } else {
                    print("User \(otherUserID) successfully removed from current user's pending friends list!")
                }
            }
            
            db.collection("users").document(otherUserID).collection("sentRequests").document(currentUserId).delete() {err in
                if let err = err {
                    print("Error removing other user's sent request: \(err)")
                } else {
                    print("Successfully removed current user from \(otherUserID)'s sent request!")
                }
            }
        }
    }
    
    
    /// Removes friends from two users' "friends" field.
    /// - parameter theOtherUserID: the other user's uid.
    func unfriend(from theOtherUserID: String) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            self.db.collection("users").document(currentUserId).collection("friends").document(theOtherUserID).delete() {err in
                if let err = err {
                    print("Error removing \(theOtherUserID) from the current user's friends collection: \(err)")
                } else {
                    print("Successfully removed \(theOtherUserID) from current user's friends collection!")
                }
            }
            self.db.collection("users").document(theOtherUserID).collection("friends").document(currentUserId).delete() {err in
                if let err = err {
                    print("Error removing the current user from the  \(theOtherUserID)'s friends collection: \(err)")
                } else {
                    print("Successfully removed the current user from \(theOtherUserID)'s friends collection!")
                }
            }
        }
    }
    
    
    
    
    @Published var addingFriends = false
    /// Adds friends two two users' "friends" field;
    ///  calls  `declineFriendRequest` to update the "sentRequests" and "requests" collections.
    /// - parameter me: the current user.
    /// - parameter otherUser: the other user.
    func connectFriend(_ me: MealqUser, with otherUser: MealqUser) {
        if let _ =  Auth.auth().currentUser {
        addingFriends = true
            self.db.collection("users").document(me.id).collection("friends").document(otherUser.id).setData([
            "uid": otherUser.id,
            "email": otherUser.email,
            "fullname": otherUser.fullname,
            "thumbnailPicURL": otherUser.thumbnailPicURL?.absoluteString ?? Constants.placeholder_pic,
            "normalPicURL": otherUser.normalPicURL?.absoluteString ?? Constants.placeholder_pic,
            "fcmToken": otherUser.fcmToken ?? ""
            ]) { err in
                if let err = err {
                    self.addingFriends = false
                    print("Error adding the other user to current user's friends collection: \(err.localizedDescription)")
                } else {
                    print("Successfully added \(otherUser.id) to current user's friends collection")
                    self.db.collection("users").document(otherUser.id).collection("friends").document(me.id).setData([
                        "uid": me.id,
                        "email": me.email,
                        "fullname": me.fullname,
                        "thumbnailPicURL": me.thumbnailPicURL?.absoluteString ?? Constants.placeholder_pic,
                        "normalPicURL": me.normalPicURL?.absoluteString ?? Constants.placeholder_pic,
                        "fcmToken": me.fcmToken ?? ""
                    ]) { err in
                        if let err = err {
                            self.addingFriends = false
                            print("Error adding the current user to the other user's friends collection: \(err.localizedDescription)")
                        } else {
                            self.addingFriends = false
                            print("Successfully added \(me.id) to the other user's friends collection")
                            self.declineFriendRequest(from: otherUser.id)
                        }
                    }
                }
            }
            
        }
    }
    

    
}


