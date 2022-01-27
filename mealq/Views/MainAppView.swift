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
  //  @State var selection: Tab = .social
    
    @StateObject var mealsManager = MealsManager()
    @StateObject var messagesManager = MessagesManager()
    @StateObject var showMealButton = ShowMealButton()
    @StateObject var activitiesManager = ActivitiesManager()
    
    @EnvironmentObject var sessionStore: SessionStore
    
    @ObservedObject private var friendsManager = FriendsManager.sharedFriendsManager
    @ObservedObject private var sharedViewManager = ViewManager.sharedViewManager
    // @State var visitedNoti = false
    

    
    var body: some View {
//        SwiftUIView()
        TabView(selection: $sharedViewManager.selectedTab) {
                ZStack {
                    CreateMealButton().zIndex(1)
                    SocialView()
                }.tabItem{Image(systemName: "person.2")}.tag(Tab.social)
                ZStack {
                    if showMealButton.showMealButton {CreateMealButton().zIndex(1)}
                   // DebugView()
                    MealsView()
                }.tabItem{Image(systemName: "mail.stack")}.tag(Tab.meals)
                .badge(mealsManager.acceptedMeals.reduce(0){$0 + $1.unreadMessages})
                ZStack {
                    CreateMealButton().zIndex(1)
                    NotificationView()
                }.tabItem{Image(systemName: "bell")}.tag(Tab.noti)
                // TODO: Figure out a way to optimize the badges
                .badge(friendsManager.pendingFriends.count + mealsManager.pendingMeals.count)
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
                        activitiesManager.getRecentActivities()
                        
                        
                    }
                }
            }
            // .environmentObject(friendsManager)
            .environmentObject(mealsManager)
            .environmentObject(messagesManager)
            .environmentObject(showMealButton)
            .environmentObject(activitiesManager)



    }
}














struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView().environmentObject(SessionStore())
    }
}
