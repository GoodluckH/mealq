//
//  FriendsManager.swift
//  mealq
//
//  Created by Xipu Li on 11/2/21.
//

import Foundation
import Firebase
import FirebaseAuth

/// A ViewModel that manages operations involving fetching and querying other users and friends.
class FriendsManager: ObservableObject {
    
    private let db = Firestore.firestore()
    private var currentUser: User?
    
    
    init() {
        Auth.auth().addStateDidChangeListener {auth, user in
            self.currentUser = auth.currentUser
        }
    }
    
    /// An array of user uids.
    /// Use this variable to store friends of the other user of choice.
    ///
    /// - SeeAlso: `getFriendsFrom`
    @Published var otherUserFriends = [String]()
    
    @Published var friends = [MealqUser]()
    @Published var pendingFriends = [MealqUser]()
    @Published var sentRequests = [MealqUser]()
    @Published var queryResult = ["friends": [MealqUser](), "others": [MealqUser]()]
    
    /// A flag to indicate whether query results from a previous async request should be stored.
    private var stopQuery = false
    
    /// Fetches a list of the current user's friends and updates `friends`.
    ///
    /// Uses Firestore's snapshot listener to only fetch and update new changes.
    ///  - SeeAlso: `friends`.
    func fetchData() {
        if let currentUser = Auth.auth().currentUser {
            db.collection("users").whereField("friends.\(currentUser.uid)", isEqualTo: 1).addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends :(  --- failed to retrieve snapshot")
                    return
                }
                DispatchQueue.main.async {
                    self.friends = documents.map { docSnapshot in
                        let data = docSnapshot.data()
                        let FirebaseID = data["uid"] as! String
                        let fullName = data["fullname"] as! String
                        let email = data["email"] as! String
                        let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                        let normalPicURL = data["normalPicURL"] as? String ?? ""
                        return MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL))
                    }
                }
            }
            
            db.collection("users").document(currentUser.uid).collection("requests").addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends requests :(  --- failed to retrieve snapshot")
                    return
                }
                
                DispatchQueue.main.async {
                self.pendingFriends = documents.map { docSnapshot in
                    let data = docSnapshot.data()
                    let FirebaseID = data["uid"] as! String
                    let fullName = data["fullname"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                    let normalPicURL = data["normalPicURL"] as? String ?? ""
                    return MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL))
                }
                }
     
            }
            
            db.collection("users").document(currentUser.uid).collection("sentRequests").addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends requests :(  --- failed to retrieve snapshot")
                    return
                }
                
                DispatchQueue.main.async {
                self.sentRequests = documents.map { docSnapshot in
                    let data = docSnapshot.data()
                    let FirebaseID = data["uid"] as! String
                    let fullName = data["fullname"] as! String
                    let email = data["email"] as! String
                    let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                    let normalPicURL = data["normalPicURL"] as? String ?? ""
                    return MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL))
                }
                }

            }
        } else {
            print("Cannot fetch current Firebase user.")
        }

    }
    
    

    
    @Published var resolvingQuery = true
    
    /// Filters the current user's friends and all other users based on query string.
    ///
    /// Performs filtering on the existing `friends` array first to optimize for user experience. The `friends` array should already been updated because `fetchData` is called before any query.
    ///
    /// - parameter text: the query string used for filtering.
    func queryString(of text: String) {
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
        if let currentUser = Auth.auth().currentUser {
            self.db.collection("users").getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Couldn't fetch documents")
                    return
                }
                self.db.collection("users").document(currentUser.uid).getDocument {  (snapshot, error) in
                    guard let data = snapshot?.data() else {
                         print("Couldn't find snapshot for current user with id: \(currentUser.uid)")
                         return
                     }
                    let myFriends = data["friends"] as! [String: Int]
                    
                    var othersResult = [MealqUser]()
                    for document in documents {
                        if myFriends[document.documentID] == nil
                            && document.documentID != currentUser.uid
                            && !self.stopQuery {
                            let docData = document.data()
                            let fullName = docData["fullname"] as! String
                            if fullName.lowercased().contains(text.lowercased()){
                                let FirebaseID = docData["uid"] as! String
                                let email = docData["email"] as! String
                                let thumbnailPicURL = docData["thumbnailPicURL"] as? String ?? ""
                                let normalPicURL = docData["normalPicURL"] as? String ?? ""
                                othersResult.append(MealqUser(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL)))
                            }
                        }
                    }
                    self.queryResult["others"]! = othersResult
                    self.resolvingQuery = false
                }
            }
        }
    }
    
    
    
    

    /// Fetches friends given a user's id and stores the result to `otherUserFriends`.
    ///
    /// - parameter id: the uid of a user.
    /// - SeeAlso: `otherUserFriends`.
    func getFriendsFrom(user id: String) {
        self.otherUserFriends = [String]()
        db.collection("users").document(id).getDocument() { (snapshot, error) in
            guard let data = snapshot?.data() else {
                print ("cannot get data from user \(id)")
                return
            }
            
            let friendsOfUser = data["friends"] as! [String: Int]
            
            friendsOfUser.forEach { friend, code in
                self.otherUserFriends.append(friend)
            }
            
        }
    }

    
    
    
    
    // -MARK: Friends Management
    
    /// Sends a friend request to the other user.
    ///
    /// Two writes to the database; one is to add the current user to the other user's "requests" collection, the other is to add the other user to the current user's "sentRequests" collection.
    ///
    /// - parameter theOtherUser: the User model of the other user to send the friend request to.
    func sendFriendRequest(to theOtherUser: MealqUser) {
        if let currentUserId = currentUser?.uid {
        
            db.collection("users").document(currentUserId).getDocument() {snapshot, error in
                guard let data = snapshot?.data() else {
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
                    "thumbnailPicURL": curThumbnailPicURL ?? Constants.placeholder_pic,
                    "normalPicURL": curNormalPicURL ?? Constants.placeholder_pic
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Friend request succesfully added to: \(theOtherUser.id)")
                    }
                }
                
                
                self.db.collection("users").document(theOtherUser.id).getDocument() {snapshot, error in
                    guard let data = snapshot?.data() else {
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
        if let currentUserId = currentUser?.uid {
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
        if let currentUserId = currentUser?.uid {
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
        if let currentUserId = currentUser?.uid {
            deleteFriend(theOtherUserID, from: currentUserId)
            deleteFriend(currentUserId, from: theOtherUserID)
        }
    }
    
    /// Adds friends two two users' "friends" field;
    ///  calls  `declineFriendRequest` to update the "sentRequests" and "requests" collections.
    /// - parameter theOtherUserID: the other user's uid.
    func connectFriend(with theOtherUserID: String) {
        if let currentUserId = currentUser?.uid {
            addFriend(theOtherUserID, from: currentUserId)
            addFriend(currentUserId, from: theOtherUserID)
        }
        // remove both users' doc references from "requests" and "sentRequests" collections.
        self.declineFriendRequest(from: theOtherUserID)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // -MARK: Helper functions

    
    private func addFriend(_ friendID: String, from myID: String) {
        db.collection("users").document(myID).setData([
            "friends": [friendID: 1]
        ], merge: true) { err in
            if let err = err {
                print("Unable to add the other user from current user's friend list: \(err)")
            } else {
                print("Successfully added \(friendID) to \(myID)'s friend list")
            }
        }
    }
    
    private func deleteFriend(_ friendID: String, from myID: String) {
        db.collection("users").document(myID).updateData([
            "friends.\(friendID)": FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Unable to delete the other user from current user's friend list: \(err)")
            } else {
                print("Successfully deleted \(friendID) from \(myID)'s friend list")
            }
        }
    }
    
}


