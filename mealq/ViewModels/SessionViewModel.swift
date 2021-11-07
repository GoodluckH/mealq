//
//  SessionViewModel.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FacebookLogin

/// A view model that handles login and logout operations.
class SessionStore: ObservableObject {
    @Published var localUser: User?
    @Published var isAnon = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private let loginManager = LoginManager()
    private let db = Firestore.firestore()
    private let authRef = Auth.auth()
    
    /// Listens to state changes made by Firebase operations.
    func listen()  {
        handle = authRef.addStateDidChangeListener {[self] (auth, user) in
            if user != nil {
                self.localUser = User(id: user!.uid,
                                      fullname: user!.displayName!,
                                      email: user!.email!,
                                      thumbnailPicURL: user!.photoURL,
                                      normalPicURL: URL(string :"\(user!.photoURL!.absoluteString)?type=large"))
                self.isAnon = false
            } else {
                self.isAnon = true
                self.localUser = nil
            }
        }
    }
    
    
    
    /// Logs the user in using `loginManager`.
    ///
    /// If successful, get the Facebook credential and sign in using `FirebaseAuth`.
    ///
    /// - SeeAlso: `loginManager`.
    func facebookLogin() {
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { [self] loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success:
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                authRef.signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("Facebook auth with Firebase error: \(error)")
                        return
                        }
                    if authResult!.additionalUserInfo!.isNewUser {
                        print("The user is new. Adding to Firestore with uid: \(authResult!.user.uid)")
                        addUserToFirestore(with: authResult!.user.uid,
                                           authResult!.user.displayName!,
                                           authResult!.user.email!,
                                           authResult!.user.photoURL!.absoluteString,
                                           "\(authResult!.user.photoURL!.absoluteString)?type=large")
                        }
                    }
                }
            }
        }

    
    /// Adds a user to the Firestore database under the "users" collection.
    ///
    /// - parameters:
    ///   - userID: the Firestore uid.
    ///   - fullName: the user's full name.
    ///   - email: the user's email address.
    ///   - thumbnailPicURL: the string representation of the user's URL address for a thumbnai sizel picture.
    ///   - normalPicURL: the string representation of the user's URL address for a normal size picture.
    private func addUserToFirestore(with userID: String,
                                    _ fullname: String,
                                    _ email: String,
                                    _ thumbnailPicURL: String = "",
                                    _ normalPicURL: String = "") {
        db.collection("users").document(userID).setData([
            "uid": userID,
            "fullname": fullname,
            "email": email,
            "thumbnailPicURL": thumbnailPicURL,
            "normalPicURL": normalPicURL,
            "friends": [:]
        ]) {err in
                if let err = err {print("Error writing document: \(err)")}
                else {print("Document successfully written!")}
                }
    }
    
        
    /// Signs the current user out through `FirebaseAuth`.
    ///
    /// - returns: whether the current user has been successfully signed out.
    func signOut(){
        do {
            try authRef.signOut()
            self.localUser = nil
            self.isAnon = true
            return
            }
        catch { return }
        }
    
    
    /// Deletes the current user and its associated data from other users.
    func deleteUser() {
        let currentUserUID = authRef.currentUser?.uid
        // delete current user's record
        if currentUserUID != nil {
            db.collection("users").document(currentUserUID!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.authRef.currentUser?.delete { error in
                        if let error = error {
                            print("unable to delete account \(self.authRef.currentUser!.uid): \(error.localizedDescription)")
                            return
                        } else {
                            print("deleted account \(currentUserUID!) from Firebase")
                            let db = Firestore.firestore()
                            
                            // delete current user's record
                            db.collection("users").document(currentUserUID!).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                }
                            }
                            // delete current user's record in other users' documents
                            db.collection("users").whereField("friends.\(currentUserUID!)", isLessThanOrEqualTo: 2).getDocuments {
                               ( snapshot, error) in
                                guard let documents = snapshot?.documents else {
                                    print("failed to retrieve snapshot")
                                    return
                                }
                                for document in documents {
                                    db.collection("users").document(document.documentID).updateData([
                                        "friends.\(currentUserUID!)": FieldValue.delete(),
                                    ]) { err in
                                        if let err = err {
                                            print("Unable to delete the current user from \(document.documentID)'s friend list: \(err)")
                                        } else {
                                            
                                            print("Successfully deleted \(currentUserUID!) from \(document.documentID)'s friend list")
                                        }
                                    }
                                }
                                //self.unbind()
                                self.localUser = nil
                                self.isAnon = true
                            }
                        }
                    }
                }
            }
        }
    
        

    }
    
    
    
    /// Unbinds `Firebase` listener.
    func unbind() {
        if let handle = handle {
            authRef.removeStateDidChangeListener(handle)
            }
        }


}
