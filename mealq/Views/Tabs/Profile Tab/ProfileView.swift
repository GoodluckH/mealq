//
//  ProfileView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var sessionStore = SessionStore()
   
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
            
            Button(action: {
                if sessionStore.signOut() {
                    print("sign out succeeded")
                }
            }){
                Text("sign out")
            }
        }
 
    }
}
































