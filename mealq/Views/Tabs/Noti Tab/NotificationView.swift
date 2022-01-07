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
                       // TODO: make this pretty
                       LottieView(fileName: "astronaut")
                   }
                else {
                    ScrollView(){
                        LazyVStack(pinnedViews: [.sectionHeaders]){
                        if !friendsManager.pendingFriends.isEmpty {
                            Section(header: SectionHeader(headerText: "friend requests")){
                                VStack{
                                    ForEach(friendsManager.pendingFriends.sorted{$0.1 > $1.1}, id: \.key) { user, time in
                                        
                                    SingleNotificationView(displayText: "\(user.fullname) wants to be your friend", user: user, now: self.now, time: time, navDest: AnyView(UserProfileView(user: user)))
                                        .onAppear() {self.now = Date()}
                                    }}
                                .padding(.bottom)
                            }
                            }
                            if !mealsManager.pendingMeals.isEmpty {
                            Section(header: SectionHeader(headerText: "meal requests")) {
                                ForEach(mealsManager.pendingMeals.sorted{$0.createdAt > $1.createdAt}, id: \.self) { meal in
                                   VStack{ SingleNotificationView(displayText: "\(meal.from.fullname) invited you for \(meal.name)", user: meal.from, now: self.now, time: meal.createdAt, navDest: AnyView(MealDetailView(meal: meal)))
                                       .onAppear() {self.now = Date()}}
                               }
                            }
                        }
                    }
                        
                        
                   }
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

