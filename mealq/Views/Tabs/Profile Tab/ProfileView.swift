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
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @ObservedObject var miniFriendsManager = MiniFriendsManager()
    @State private var showUserDeletion = false
    @State private var showFriends = false
    @State private var showingAlert = false
    
    var body: some View {
            
        VStack{
            HStack {
                Text("my profile")
                    .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                Spacer()
            }
            .padding()
            
            if sessionStore.deletingUser {
          
            GeometryReader{ geometry in
                VStack{
                    ActivityIndicatorView(isVisible: .constant(true), type: .equalizer)
                        .foregroundColor(.primary)
                        .frame(width: geometry.size.width/10, height: geometry.size.width/10, alignment: .center)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        } else {
            VStack {
                if !sessionStore.isAnon {
            
                    ProfilePicView(picURL: sessionStore.localUser?.normalPicURL)
                           .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                      
                    if let user = sessionStore.localUser {
                        Text(user.fullname)
                            .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                        Text("\(friendsManager.friends.count) friends")
                               .customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: .semibold)
                               .onTapGesture {showFriends = true}
                               .fullScreenCover(isPresented: $showFriends) {
                                   UserFriends(showSearchFriendSheet: $showFriends, friends: miniFriendsManager.friendsOfQueriedUser)
                                       .onAppear{
                                           if !miniFriendsManager.queriedFriends {miniFriendsManager.getFriendsFrom(user.id)}
                                       }
                               }
                            
                    }
               else
                    {
                   Text(sessionStore.localUser?.fullname ?? "Rando")
                           .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
               }
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
                
                Button("contact developer") {
                    showingAlert = true
                }.alert("Hi there!", isPresented: $showingAlert)
                {} message: {
                    Text("contact us at mealq.app@gmail.com")
                }
            
            }.padding()
        }
        
        
        }.frame(maxHeight: .infinity, alignment: .top)
        }
}























