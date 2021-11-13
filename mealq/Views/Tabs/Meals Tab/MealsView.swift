//
//  MealsView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct MealsView: View {
    
    @EnvironmentObject var friendsManager: FriendsManager
    
     var body: some View {
         NavigationView{
             VStack{
                 HStack {
                     Text("friend requests")
                         .padding()
                         .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .bold)
                 }
         
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
             } .navigationBarHidden(true)
                 .navigationBarTitle(Text(""))
         }
     }
}






































struct MealsView_Previews: PreviewProvider {
    static var previews: some View {
        MealsView().environmentObject(FriendsManager())
    }
}
