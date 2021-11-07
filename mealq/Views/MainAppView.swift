//
//  MainAppView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

enum Tab {
    case social, meals, profile, test
}

struct MainAppView: View {
    @State var selection: Tab = .social
    
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
                
            
            ProfileView().tabItem{Image(systemName: "person")}.tag(Tab.profile)
            
        }
        

        //.onAppear{
//            let apparence = UITabBarAppearance()
//            apparence.configureWithOpaqueBackground()
//            if #available(iOS 15.0, *) {UITabBar.appearance().scrollEdgeAppearance = apparence}
       // }
        .font(Font.custom("Quicksand-SemiBold", size: 17))
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
