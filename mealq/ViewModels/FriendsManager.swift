//
//  FriendsManager.swift
//  mealq
//
//  Created by Xipu Li on 11/2/21.
//

import Foundation
import Firebase

/// A ViewModel that manages operations involving fetching and querying other users and friends.
///
/// `friends` code:
///                 1: connected friend
///                 2: pending friend request
class FriendsManager: ObservableObject {
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    
    /// An array of user uids.
    ///
    /// Use this variable to store friends of other users other than the current user.
    @Published var otherUserFriends = [String]()
    
    @Published var friends = [1: [User](), 2: [User]()]
    @Published var queryResult = ["friends": [User](), "others": [User]()]
    
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
                    self.friends[1] = documents.map { docSnapshot in
                        let data = docSnapshot.data()
                        let FirebaseID = data["uid"] as! String
                        let fullName = data["fullname"] as! String
                        let email = data["email"] as! String
                        let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                        let normalPicURL = data["normalPicURL"] as? String ?? ""
                        return User(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL))
                    }
                }
             
            }
            
            db.collection("users").whereField("friends.\(currentUser.uid)", isEqualTo: 2).addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no friends :(")
                    return
                }
                DispatchQueue.main.async {
                    self.friends[2] = documents.map { docSnapshot in
                        let data = docSnapshot.data()
                        let FirebaseID = data["uid"] as! String
                        let fullName = data["fullname"] as! String
                        let email = data["email"] as! String
                        let thumbnailPicURL = data["thumbnailPicURL"] as? String ?? ""
                        let normalPicURL = data["normalPicURL"] as? String ?? ""
                        return User(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL))
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
            queryResult = ["friends": [User](), "others": [User]()]
            stopQuery = true
            return
        }
        self.resolvingQuery = true
        
        // Filters friends based on query string.
        self.queryResult["friends"]! = self.friends[1]!.filter {$0.fullname.lowercased().contains(text.lowercased())}
    
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
                    
                    var othersResult = [User]()
                    for document in documents {
                        if (myFriends[document.documentID] == nil || myFriends[document.documentID] == 2)
                            && document.documentID != currentUser.uid
                            && !self.stopQuery {
                            let docData = document.data()
                            let fullName = docData["fullname"] as! String
                            if fullName.lowercased().contains(text.lowercased()){
                                let FirebaseID = docData["uid"] as! String
                                let email = docData["email"] as! String
                                let thumbnailPicURL = docData["thumbnailPicURL"] as? String ?? ""
                                let normalPicURL = docData["normalPicURL"] as? String ?? ""
                                othersResult.append(User(id: FirebaseID, fullname: fullName, email: email, thumbnailPicURL: URL(string: thumbnailPicURL), normalPicURL: URL(string:normalPicURL)))
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
                if code == 1 {
                    self.otherUserFriends.append(friend)
                }
            }
            
        }
    }
    
    
    
    
    
    
    func sendFriendRequest(me myID: String, theOtherUser otherUserID: String) {
        db.collection("users").document(otherUserID).setData([
            "friends": [myID: 2]
        ], merge: true) { err in
            if let err = err {
                print("Unable to add the other user from current user's friend list: \(err)")
            } else {
                print("Successfully sent request to \(otherUserID) from \(myID)")
            }
        }
    }
    
    
    func unsendFriendRequest(me myID: String, theOtherUser otherUserID: String) {
        deleteFriend(myID, from: otherUserID)
    }
    
    
    func unfriend(me myID: String, theOtherUser otherUserID: String) {
        deleteFriend(otherUserID, from: myID)
        deleteFriend(myID, from: otherUserID)
        //otherUserFriends.remove
    }
    
    
    func connectFriend(me myID: String, theOtherUser otherUserID: String) {
        addFriend(otherUserID, from: myID)
        addFriend(myID, from: otherUserID)
        //otherUserFriends.append()
    }
    
    
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

