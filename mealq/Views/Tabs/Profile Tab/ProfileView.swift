//
//  ProfileView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import ActivityIndicatorView

struct ProfileView: View {
    @ObservedObject var sessionStore = SessionStore()
    @State private var showUserDeletion = false
    init() {
        sessionStore.listen()
    }
    
    var body: some View {
        
            VStack {
                if !sessionStore.isAnon {
            
                    Text(sessionStore.localUser!.fullname.lowercased())
                    ProfilePicView(picURL: sessionStore.localUser!.normalPicURL)
                        .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)

                    }
                
                Button("sign out")  {
                    sessionStore.signOut()
                    print("sign out succeeded")
                    }
                
                Button("delete account") {
                    showUserDeletion = true
                }
                .foregroundColor(.red)
                .confirmationDialog("You will need to sign in again with Facebook to delete your account. Are you sure?", isPresented: $showUserDeletion , titleVisibility: .visible) {
                    Button("Delete Account", role: .destructive) {
                        sessionStore.deleteUser()
                    }
                    
                }
            
        }
        }
}























