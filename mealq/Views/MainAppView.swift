//
//  MainAppView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Firebase
import FirebaseAuth

enum Tab {
    case social, meals, profile, noti, test
}

struct MainAppView: View {
    @State var selection: Tab = .social
    @StateObject var friendsManager = FriendsManager()
    @StateObject var mealsManager = MealsManager()
    @StateObject var messagesManager = MessagesManager()
    @StateObject var showMealButton = ShowMealButton()
    
    @EnvironmentObject var sessionStore: SessionStore
   
    @State var visitedNoti = false
    

    
    var body: some View {
//        SwiftUIView()
            TabView(selection: $selection) {
                ZStack {
                    CreateMealButton().zIndex(1)
                    SocialView()
                }.tabItem{Image(systemName: "person.2")}.tag(Tab.social)
                ZStack {
                    if showMealButton.showMealButton {CreateMealButton().zIndex(1)}
                    MealsView()
                }.tabItem{Image(systemName: "mail.stack")}.tag(Tab.meals)
                ZStack {
                    CreateMealButton().zIndex(1)
                    NotificationView()
                }.onAppear{visitedNoti = true}.tabItem{Image(systemName: "bell")}.tag(Tab.noti)
                // TODO: Figure out a way to optimize the badges
                .badge(visitedNoti ? 0: (friendsManager.pendingFriends.count + mealsManager.pendingMeals.count))
                ZStack {
                    CreateMealButton().zIndex(1)
                    ProfileView()
                }.tabItem{Image(systemName: "person")}.tag(Tab.profile)


        }.customFont(name: "Quicksand-SemiBold", style: .body)
            .task{
                Auth.auth().addStateDidChangeListener {_, user in
                    if let _ = user {
                        friendsManager.fetchData()
                        mealsManager.fetchMeals()
                    }
                }
            }.environmentObject(friendsManager)
            .environmentObject(mealsManager)
            .environmentObject(messagesManager)
            .environmentObject(showMealButton)



    }
}














struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView().environmentObject(SessionStore())
    }
}
