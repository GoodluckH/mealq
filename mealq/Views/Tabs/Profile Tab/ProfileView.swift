//
//  ProfileView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import ActivityIndicatorView

struct ProfileView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var friendsManager: FriendsManager
    @State private var showUserDeletion = false

    
    var body: some View {
        
            VStack {
                if !sessionStore.isAnon {
            
                    ProfilePicView(picURL: sessionStore.localUser?.thumbnailPicURL)
                           .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                      
                    Text(sessionStore.localUser?.fullname ?? "Rando")
                           .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                    
                    Text("\(friendsManager.friends.count) friends")
                           .customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: .semibold)
                    }
                
                
                Button("sign out")  {
                    sessionStore.signOut()
                    print("sign out succeeded")
                }.padding(.top)
                
                Button("delete account") {
                    showUserDeletion = true
                }
                .foregroundColor(.red)
                .confirmationDialog("You will need to sign in again with Facebook to delete your account. Are you sure? \n DEV_NOTE: If you are a reviewer from Apple using a demo account, please STOP right here and click cancel!", isPresented: $showUserDeletion , titleVisibility: .visible) {
                    Button("Delete Account", role: .destructive) {
                        sessionStore.deleteUser()
                    }
                    
                }
            
            }.padding()
        }
}























