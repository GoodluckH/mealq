//
//  UserProfileView.swift
//  mealq
//
//  Created by Xipu Li on 11/4/21.
//

import SwiftUI

struct UserProfileView: View {
    var user: MealqUser
    @EnvironmentObject var friendsManager: FriendsManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showBigPic = false
    
    // TODO: try to optimize this 
    @State var cachedImage: Image?
    
    
    var goBackButton: some View {
        Button(action: {self.presentationMode.wrappedValue.dismiss()
        }){
        Image(systemName: "xmark")
            .font(.body.weight(.bold))
        }
        .padding(.top)
        .foregroundColor(Color("MyPrimary"))
      
    }

    var body: some View {
            if showBigPic {
                BigUserPicView(image: cachedImage).onTapGesture{showBigPic = false}
            }
            else {
                VStack {
                    ProfilePicView(picURL: URL(string: "https://graph.facebook.com/3052875971654831/picture?width=1000&height=1000"), cachedImage: $cachedImage)
                        .onTapGesture{
                            withAnimation(.easeOut) {
                                showBigPic = true
                            }
                        }
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
               
           } //else
    }
        
        
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: MealqUser(id: "5s2dfasdgasdfsa", fullname: "someone", email: "trump@nb.com", thumbnailPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/128px-Donald_Trump_official_portrait.jpg"), normalPicURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Donald_Trump_official_portrait.jpg/512px-Donald_Trump_official_portrait.jpg"))).environmentObject(FriendsManager())
    }
}
