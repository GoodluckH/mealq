//
//  ConnectButton.swift
//  mealq
//
//  Created by Xipu Li on 11/4/21.
//

import SwiftUI
import Firebase

struct ConnectButton: View {
    var user: User
   @EnvironmentObject var friendsManager: FriendsManager
    
    
    var body: some View {
        EmptyView()
        // if the user is already a friend, then when clicked, the button should remove the friendship
        // otherwise, build a new friendship by sending a request
        // if the potential friend's uid is in friendRequest, then display pending
        // if the other friend accepts the request, remove the thing from friendRequest, and do the connectFriend method.
        
        

        if friendsManager.friends[1]!.contains(user) {
                Button(action: {
                    friendsManager.unfriend(me: Auth.auth().currentUser!.uid, theOtherUser: user.id)
                }) {
                    Text("unfriend")
                }
        } else if friendsManager.friends[2]!.contains(user) {
            Button(action: {
                /// - Todo
            }) {
                Text("Pending, click to cancel request")
            }
        }

        else {
            Button(action: {
                friendsManager.sendFriendRequest(me: Auth.auth().currentUser!.uid, theOtherUser: user.id)
            }) {
                Text("Send Request")
            }
        }
    
    
    
    
    }
}

//struct ConnectButton_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        ConnectButton(myFriends: [1: [User](), 2: [User]()], user: User(id: "salfjal;sdf", fullname: "Mike Kim", email: "elas@lksd") , friendsManager: FriendsManager())
//    }
//}
