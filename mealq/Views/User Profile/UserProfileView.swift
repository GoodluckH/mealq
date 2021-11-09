//
//  UserProfileView.swift
//  mealq
//
//  Created by Xipu Li on 11/4/21.
//

import SwiftUI

struct UserProfileView: View {
    var user: User
    @EnvironmentObject var friendsManager: FriendsManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var goBackButton: some View {
        Button(action: { self.presentationMode.wrappedValue.dismiss()
        }){
            Text("go back")
        }
    }

    var body: some View {
        
           VStack {

            ProfilePicView(picURL: user.thumbnailPicURL)
                   .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
               Text(user.fullname)
                   .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
               Text("\(friendsManager.otherUserFriends.count) friends")
                   .customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: .semibold)
                   
                   
               ConnectButton(user: user).padding(.top).padding(.horizontal)
                   
                   
               
               Spacer()
           }
           .padding(.top)
           .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: goBackButton)
    }
        
        
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: User(id: "5s2dfasdgasdfsa", fullname: "someone", email: "trump@nb.com", thumbnailPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/128px-Donald_Trump_official_portrait.jpg"), normalPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/512px-Donald_Trump_official_portrait.jpg"))).environmentObject(FriendsManager())
    }
}
