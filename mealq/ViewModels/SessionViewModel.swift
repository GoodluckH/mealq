//
//  SessionViewModel.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FacebookLogin

/// A view model that handles login and logout operations.
class SessionStore: ObservableObject {
    @Published var localUser: MealqUser?
    @Published var isAnon = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private let loginManager = LoginManager()
    private let db = Firestore.firestore()
    private let authRef = Auth.auth()
    

   // \(user!.photoURL!.absoluteString)
    /// Listens to state changes made by Firebase operations.
    func listen()  {
        handle = authRef.addStateDidChangeListener {[self] (auth, user) in
            if user != nil {
                self.localUser = MealqUser(id: user!.uid,
                                      fullname: user!.displayName ?? "Rando",
                                      email: user!.email!,
                                      thumbnailPicURL: user!.photoURL,
                                      normalPicURL: URL(string :"\(user!.photoURL?.absoluteString ?? "none")?type=large"))
                Messaging.messaging().token { token, error in
                    Firestore.firestore().collection("users").document(user!.uid).setData(["fcmToken": token ?? ""], merge: true) {err in
                       if let err = err {
                           print("Unable to add the new fcm token to Firestore db: \(err)")
                       } else {
                           print("Successfully sent fresh token Firestore")
                       }
                    }
                    
                }
                    
                self.isAnon = false
            } else {
                self.isAnon = true
                self.localUser = nil
            }
        }
    }
    
    
    
    func demoLogin() {
        
        authRef.signIn(withEmail: "test@test.com", password: "12345678")
        
        // Create a new demo account
//        authRef.createUser(withEmail: "test@test.com", password: "12345678") { result,err in
//            if let err = err {
//                print("something went wrong when logining demo account: \(err.localizedDescription)")
//                return
//            }
//            result!.user.createProfileChangeRequest().displayName = "Apple Tester"
//            self.addUserToFirestore(with: result!.user.uid, result!.user.displayName!, result!.user.email!)
//
//        }
    }
    
    @Published var fbSigningIn = false
    /// Logs the user in using `loginManager`.
    ///
    /// If successful, get the Facebook credential and sign in using `FirebaseAuth`.
    ///
    /// - SeeAlso: `loginManager`.
    func facebookLogin() {
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { [self] loginResult in
            fbSigningIn = true
            switch loginResult {
            case .failed(let error):
                fbSigningIn = false
                print(error)
            case .cancelled:
                fbSigningIn = false
                print("User cancelled login.")
            case .success:
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                authRef.signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("Facebook auth with Firebase error: \(error)")
                        return
                        }
                    fbSigningIn = false
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

        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
              self.db.collection("users").document(userID).setData([
                "uid": userID,
                "fullname": fullname,
                "email": email,
                "thumbnailPicURL": thumbnailPicURL,
                "normalPicURL": normalPicURL,
                "friends": [:],
                "fcmToken": ""
              ]) {err in
                    if let err = err {print("Error writing document: \(err)")}
                    else {print("Document successfully written!")}
                    }
              
          } else if let token = token {
            print("FCM registration token: \(token)")
            self.db.collection("users").document(userID).setData([
              "uid": userID,
              "fullname": fullname,
              "email": email,
              "thumbnailPicURL": thumbnailPicURL,
              "normalPicURL": normalPicURL,
              "friends": [:],
              "fcmToken": token
            ]) {err in
                  if let err = err {print("Error writing document: \(err)")}
                  else {print("Document successfully written!")}
                  }
          }
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
            }
        catch { return }
        }
    
    
    @Published var deletingUser = false
    /// Deletes the current user and its associated data from other users.
    func deleteUser() {
        let currentUserUID = authRef.currentUser?.uid
        if currentUserUID != nil {

            self.loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { loginResult in
                self.deletingUser = true
                switch loginResult {
                case .failed(let error):
                    self.deletingUser = false
                    print(error)
                case .cancelled:
                    self.deletingUser = false
                    print("User cancelled login. Deletion process halted.")
                case .success:
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    self.authRef.currentUser?.reauthenticate(with: credential) { result, error in
                        if let error = error {
                            self.deletingUser = false
                            print("Unable to reauthenticate user: \(error)")
                        } else {
                            // delete current user's record from Firestore
                            self.db.collection("users").document(currentUserUID!).delete() { err in
                                if let err = err {
                                    self.deletingUser = false
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                    
                                    // ----------------------------------------------------------------------
                                    // --------- DELETE CURRENT USER FROM OTHER USER'S FRIEND LISTS ---------
                                    self.db.collection("users").whereField("friends.\(currentUserUID!)", isEqualTo: 1).getDocuments {
                                       ( snapshot, error) in
                                        guard let documents = snapshot?.documents else {
                                            self.deletingUser = false
                                            print("failed to retrieve snapshot")
                                            return
                                        }
                                        for document in documents {
                                            self.db.collection("users").document(document.documentID).updateData([
                                                "friends.\(currentUserUID!)": FieldValue.delete(),
                                            ]) { err in
                                                if let err = err {
                                                    self.deletingUser = false
                                                    print("Unable to delete the current user from \(document.documentID)'s friend list: \(err)")
                                                } else {
                                                    print("Successfully deleted \(currentUserUID!) from \(document.documentID)'s friend list")

                                                }
                                            }
                                        }
                                        
                                        // -----------------------------------------------------
                                        // --------- DELETE CURRENT USER FROM FIREBASE ---------
                                        self.authRef.currentUser?.delete { error in
                                            self.deletingUser = false
                                            if let error = error {
                                                print("unable to delete account \(self.authRef.currentUser!.uid): \(error.localizedDescription)")
                                                return
                                            } else {
                                                print("deleted account \(currentUserUID!) from Firebase")
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
