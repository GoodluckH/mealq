//
//  SingleFriendRequestRow.swift
//  mealq
//
//  Created by Xipu Li on 11/12/21.
//

import SwiftUI
import ActivityIndicatorView

struct SingleNotificationView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var sessionStore: SessionStore
    
    
    var displayText: String 
    var user: MealqUser
    var now: Date
    var time: Date
    
    var navDest: AnyView
    
    var body: some View {
        GeometryReader {geometry in
            
          ZStack {
              RoundedRectangle(cornerRadius: Constants.roundedRectShadowRadius * 1.7)
                  .fill(Color("QueryLoaderStartingColor"))
                  .shadow(color: .gray, radius:  Constants.isPressedShadowRadius, y: Constants.roundedRectShadowYOffset)
              
                    NavigationLink(destination: navDest){
                        ProfilePicView(picURL: user.normalPicURL).frame(width: geometry.size.width/6, height: geometry.size.width/6)
                            .padding(.leading)
                            VStack(alignment:.leading) {
                                Text(displayText)
                                    .customFont(name: "Quicksand-SemiBold", style: .body)
                                    .foregroundColor(Color("MyPrimary"))
  
                                Spacer()
                                Text(dateToString(from: time,to: now))
                                        .customFont(name: "Quicksand-SemiBold", style: .footnote)
                                        .foregroundColor(.gray)
                            }.padding(.vertical)
                    Spacer()

                    }

       

            }

            
           

        }.padding().frame(height: UIScreen.main.bounds.width / 5)
            .padding(.bottom, 5)
   
    }
}




























//
//
//
//
//
//struct SingleFriendRequestRow_Previews: PreviewProvider {
//    static let user = MealqUser(id: "asdfsdf", fullname: "test", email: "sdf@lsd.com")
//    static var previews: some View {
//        SingleFriendRequestRow(user: user)
//    }
//}
