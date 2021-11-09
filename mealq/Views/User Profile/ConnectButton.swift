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
    @State private var showPendingSheet = false
    @State private var showUnfriendSheet = false
    
    var body: some View {

        GeometryReader{ geometry in
     
            // if it's a friend, then display the button for removing this friend
            if friendsManager.friends[1]!.contains(user) {
                HStack{
                    Spacer()
                    Button(action: {showUnfriendSheet = true}) {
                        HStack{
                            Image(systemName: "checkmark")
                            Text("connected")
                        }
                      }.customFont(name: "Quicksand-SemiBold", style: .headline, weight: .black)
                       .foregroundColor(.blue)
                       .padding(.vertical, 10)
                       .frame(width: geometry.size.width/2)
                       .background(Capsule().strokeBorder(Color.blue, lineWidth: 2))
                       .confirmationDialog("Are you sure you don't want to be friends with \(user.fullname)?", isPresented: $showUnfriendSheet, titleVisibility: .visible) {
                           Button("Unfriend", role: .destructive) {
                               friendsManager.unfriend(me: Auth.auth().currentUser!.uid, theOtherUser: user.id)
                           }
                       }
                    Spacer()
                }
            }
            
            
            // if this user has no accepted the friend request, then show the pending button
            else if friendsManager.friends[2]!.contains(user) {
                HStack{
                    Spacer()
                    Button("pending") {showPendingSheet = true}
                        .customFont(name: "Quicksand-SemiBold", style: .headline, weight: .bold)
                       .foregroundColor(.blue)
                       .padding(.vertical, 10.0)
                       .frame(width: geometry.size.width/2)
                       .background(Capsule().strokeBorder(Color.blue, lineWidth: 2))
                       .confirmationDialog("Cancel friend request to \(user.fullname)?", isPresented: $showPendingSheet, titleVisibility: .visible) {
                       Button("Unsend friend request", role: .destructive) {
                           friendsManager.unsendFriendRequest(me: Auth.auth().currentUser!.uid, theOtherUser: user.id)
                       }
                   }
                    Spacer()
                }
            }
              
            
            
            // if this user is not a friend nor there's any friend request, show add-friend button
            else {
                HStack{
                    Spacer()
                    Button(action: {
                        friendsManager.sendFriendRequest(me: Auth.auth().currentUser!.uid, theOtherUser: user.id)
                    }) {
                      HStack{
                          Image(systemName: "person.fill.badge.plus")
                          Text("add friend")
                              .customFont(name: "Quicksand-SemiBold", style: .headline, weight: .bold)
                      }
                      }
                       .foregroundColor(.white)
                       .padding(.vertical, 10.0)
                       .frame(width: geometry.size.width/2)
                       .background(Color.blue)
                       .clipShape(Capsule())
                    Spacer()
                }
            }
                
                
                
                
                
            } // GeometryReader
        } // body
    }




























struct ConnectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        ConnectButton(user: User(id: "salfjal;sdf", fullname: "Mike Kim", email: "elas@lksd")).environmentObject(FriendsManager())
    }
}

