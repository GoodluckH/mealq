//
//  SocialView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct SocialView: View {

    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @EnvironmentObject var activitiesManager: ActivitiesManager

    var body: some View {
            NavigationView{
            VStack{
                HStack {
                    Text("activities")
                        .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                    Spacer()
                    SearchButton()
                }.padding()
                
                    
               VStack {
                   ActivitiesZone()               
               }
                
                
                        
                }.navigationBarHidden(true)
                    .navigationBarTitle(Text(""))
                }.navigationViewStyle(.stack)

        }
    }



