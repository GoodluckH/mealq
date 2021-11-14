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
    case social, meals, profile, test
}

struct MainAppView: View {
    @State var selection: Tab = .social
    @StateObject var friendsManager = FriendsManager()
    @EnvironmentObject var sessionStore: SessionStore
    
    
    
    var body: some View {
        TabView(selection: $selection) {
            ZStack{
                CreateMealButton().zIndex(1)
                SocialView()
            }
            .tabItem{Image(systemName: "person.2")}.tag(Tab.social)
            
            ZStack{
                CreateMealButton().zIndex(1)
                MealsView()
            }.tabItem{Image(systemName: "mail.stack")}.tag(Tab.meals)
            
            ProfileView()
                .tabItem{Image(systemName: "person")}.tag(Tab.profile)
                //.onAppear{sessionStore.listen()}
            
        }.customFont(name: "Quicksand-SemiBold", style: .body)
            .task{
                Auth.auth().addStateDidChangeListener {_, user in
                    if let _ = user {
                        friendsManager.fetchData()
                    }
                }
            }
            .environmentObject(friendsManager)
        

        //.onAppear{
//            let apparence = UITabBarAppearance()
//            apparence.configureWithOpaqueBackground()
//            if #available(iOS 15.0, *) {UITabBar.appearance().scrollEdgeAppearance = apparence}
       // }
        
    }
}














struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView().environmentObject(SessionStore())
    }
}
