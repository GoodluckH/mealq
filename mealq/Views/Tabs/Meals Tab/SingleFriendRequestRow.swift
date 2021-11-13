//
//  SingleFriendRequestRow.swift
//  mealq
//
//  Created by Xipu Li on 11/12/21.
//

import SwiftUI

struct SingleFriendRequestRow: View {
    @EnvironmentObject var friendsManager: FriendsManager
    var user: User
    var body: some View {
        GeometryReader {geometry in
           
                HStack {
      
                    NavigationLink(destination: UserProfileView(user: user)){
                        ProfilePicView().frame(width: geometry.size.width/7, height: geometry.size.width/7)
                            .padding()
                        Text(user.fullname)
                    }
                    
                    Spacer()
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
                        friendsManager.connectFriend(with: user.id)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .background(.green)
                            
                    }
                    .clipShape(Circle()).frame(width: geometry.size.width/8, height: geometry.size.width/8)
                    .padding()
                    
                }.customFont(name: "Quicksand-SemiBold", style: .title2)

        }.padding()
   
    }
}

































struct SingleFriendRequestRow_Previews: PreviewProvider {
    static let user = User(id: "asdfsdf", fullname: "test", email: "sdf@lsd.com")
    static var previews: some View {
        SingleFriendRequestRow(user: user)
    }
}
