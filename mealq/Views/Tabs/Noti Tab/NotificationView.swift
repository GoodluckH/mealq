//
//  FriendRequestsView.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI
import Foundation
import Combine

struct NotificationView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var mealsManager: MealsManager
    @State var now = Date()
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    
  
    var body: some View {
        NavigationView{
        
            VStack{
                
                HStack {
                    Text("notifications")
                        .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                    Spacer()
                    SearchButton()
                }
                .padding()
                
              HStack{
                   
                   if friendsManager.pendingFriends.isEmpty && mealsManager.pendingMeals.isEmpty {
                       LottieView(fileName: "astronaut")
                   }
                else {
                    List {
                        ForEach(combineArrays(friendsManager.pendingFriends, mealsManager.pendingMeals).sorted {$0.timeStamp > $1.timeStamp}, id: \.id) { item in
                            
                            SingleNotificationView(notificationItem: item, now: self.now)
                            
                    }
                }.listStyle(.plain)
                }
                   
              }.frame(maxHeight:.infinity)
            
            }.navigationBarTitle("")
                .navigationBarHidden(true)

        }.navigationViewStyle(.stack)
    }

}

//struct FriendRequestsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendRequestsView().environmentObject(FriendsManager())
//    }
//}

