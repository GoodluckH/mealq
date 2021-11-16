//
//  SingleFriendRequestRow.swift
//  mealq
//
//  Created by Xipu Li on 11/12/21.
//

import SwiftUI
import ActivityIndicatorView

struct SingleFriendRequestRow: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var sessionStore: SessionStore
    var user: MealqUser
    var body: some View {
        GeometryReader {geometry in
           
                HStack {
      
                    NavigationLink(destination: UserProfileView(user: user)){
                        ProfilePicView(picURL: user.normalPicURL).frame(width: geometry.size.width/7, height: geometry.size.width/7)
                            .padding()
                        Text(user.fullname)
                    }
                    
                    Spacer()
                    
                    if !friendsManager.addingFriends {
                        Button(action: {
                            friendsManager.declineFriendRequest(from: user.id)
                        }) {
                            Image(systemName: "xmark")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .background(.red)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            friendsManager.connectFriend(sessionStore.localUser!, with: user)
                        }) {
                            Image(systemName: "checkmark")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .background(.green)
                                
                        }
                        .clipShape(Circle()).frame(width: geometry.size.width/8, height: geometry.size.width/8)
                        .padding()
                    } else {
                        ActivityIndicatorView(isVisible: .constant(true), type: .equalizer)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(width: geometry.size.width/6, height: geometry.size.width/10, alignment: .center)
                    }
                    
                    
                }.customFont(name: "Quicksand-SemiBold", style: .title2)

        }//.padding()
   
    }
}

































struct SingleFriendRequestRow_Previews: PreviewProvider {
    static let user = MealqUser(id: "asdfsdf", fullname: "test", email: "sdf@lsd.com")
    static var previews: some View {
        SingleFriendRequestRow(user: user)
    }
}
