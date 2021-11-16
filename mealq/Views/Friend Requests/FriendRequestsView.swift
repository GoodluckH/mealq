//
//  FriendRequestsView.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct FriendRequestsView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @Binding var showNavLinkView: Bool
    var body: some View {
        NavigationView{
            VStack{
               HStack{
                   Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .onTapGesture{ showNavLinkView = false}
                   Spacer()
               }.padding(.top).padding(.horizontal)
                
                
                Text("friend requests")
                    .padding(.horizontal)
                    .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .bold)
        
               HStack{
                   if friendsManager.pendingFriends.isEmpty {
                    Text("you have no friend requests for now")
                }
                else {
                    ScrollView{
                        ForEach(friendsManager.pendingFriends, id: \.id) { user in
                                SingleFriendRequestRow(user: user)
                                .padding(.vertical)
                        }
                   }
                }
                   
               }.frame(maxHeight:.infinity, alignment: .top)
            
            }.navigationBarTitle("")
                .navigationBarHidden(true)

        }
    }
}

//struct FriendRequestsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendRequestsView().environmentObject(FriendsManager())
//    }
//}
