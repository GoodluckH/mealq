//
//  FriendSelection.swift
//  mealq
//
//  Created by Xipu Li on 11/18/21.
//

import SwiftUI

struct FriendSelection: View {
    @Binding var selectedFriends: [MealqUser]
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    // Debug
    var friends = [MealqUser(id: "sdfasdfdsfsd", fullname: "John Jomme", email: "slfsd@sdf.com"),
      MealqUser(id: "sdsadffasdfdsfsd", fullname: "Tim Cook", email: "slfs2d@sdf.com"),
      MealqUser(id: "sdsadffasdfdsfdfsd", fullname: "Elon Musk", email: "slfsdfd@sdf.com"),
      MealqUser(id: "sdsadffasdfdsf123fsd", fullname: "Halo Chief", email: "slf3fsd@sdf.com"),
      MealqUser(id: "sdsadffasdfdsf2sd", fullname: "Some Dude", email: "slfsddf@sdf.com"),
    ]
    var body: some View {
            ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(friendsManager.friends, id: \.id) { friend in
                    SingleFriendPane(user: friend, selectedFriends: $selectedFriends)
                        
                       
                }.frame(width: paneWidth, height: paneHeight, alignment: .center)
                    //.padding()
                    
            }.padding()
        
        } // ScrollView
            
            
    }
    
    private let paneWidth: CGFloat = 100
    private let paneHeight: CGFloat = 120
    
    
    
}



















//struct FriendSelection_Previews: PreviewProvider {
//    
//    static var selectedFriends = [MealqUser(id: "sdfasdfdsfsd", fullname: "John Jomme", email: "slfsd@sdf.com"),
//      MealqUser(id: "sdsadffasdfdsfsd", fullname: "Tim Cook", email: "slfs2d@sdf.com"),
//      MealqUser(id: "sdsadffasdfdsfdfsd", fullname: "Elon Musk", email: "slfsdfd@sdf.com"),
//      MealqUser(id: "sdsadffasdfdsf123fsd", fullname: "Halo Chief", email: "slf3fsd@sdf.com"),
//      MealqUser(id: "sdsadffasdfdsf2sd", fullname: "Some Dude", email: "slfsddf@sdf.com"),
//    ]
//    static var previews: some View {
//        FriendSelection(selectedFriends: [MealqUser]().Binding).environmentObject(FriendsManager())
//    }
//}

