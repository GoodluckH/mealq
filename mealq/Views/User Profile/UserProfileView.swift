//
//  UserProfileView.swift
//  mealq
//
//  Created by Xipu Li on 11/4/21.
//

import SwiftUI

struct UserProfileView: View {
    var user: MealqUser
    @EnvironmentObject var sessionStore: SessionStore
    @ObservedObject var friendsManager = MiniFriendsManager()
    @State private var showBigPic = false
    @State private var showFriends = false


    var body: some View {
     
                VStack {
                    ProfilePicView(picURL: user.normalPicURL)
                        .onTapGesture{showBigPic = true}
                       .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                       .sheet(isPresented: $showBigPic) {
                           BigUserPicView(picURL: URL(string: ((user.thumbnailPicURL?.absoluteString) != nil) ? user.thumbnailPicURL!.absoluteString + "?width=1000&height=1000" : ""))
                       }
                       
                   Text(user.fullname)
                       .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                   Text("\(friendsManager.friendsOfQueriedUser.count) friends")
                       .customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: .semibold)
                       .onTapGesture {showFriends = true}
                       .fullScreenCover(isPresented: $showFriends) {
                           UserFriends(showSearchFriendSheet: $showFriends, friends: friendsManager.friendsOfQueriedUser)
                       }
                    if sessionStore.localUser != user {ConnectButton(user: user).padding(.top).padding(.horizontal)}
                       
                   Spacer()
                }.onAppear{
                    if !friendsManager.queriedFriends {friendsManager.getFriendsFrom(user.id)}
                }
               .padding(.top)
               //.navigationBarBackButtonHidden(true)
               // .navigationBarItems(leading: goBackButton)
               
         
    }
        
        
}

//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfileView(user: MealqUser(id: "5s2dfasdgasdfsa", fullname: "someone", email: "trump@nb.com", thumbnailPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/128px-Donald_Trump_official_portrait.jpg"), normalPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/512px-Donald_Trump_official_portrait.jpg"))).environmentObject(FriendsManager())
//    }
//}
