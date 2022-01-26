//
//  SocialView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct SocialView: View {

    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var activitiesManager: ActivitiesManager

    var body: some View {
            NavigationView{
            VStack{
                HStack {
                    Text("activities")
                        .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                    Spacer()
                    // AlertButton()
                      //  .padding(.horizontal)
                    SearchButton()
                }
                .padding()
                    
                if activitiesManager.loadingActivities == .loading {
                    Text("Loading..")
                    Spacer()
                } else {
                    if activitiesManager.activities.isEmpty {
                        Text("Empty feed")
                        Spacer()
                    } else {
                        List (activitiesManager.activities) { act in
                            VStack(alignment: .leading){
                                Text("\(act.from.fullname) invited \(act.to.count) other people for \(act.name)\(act.weekday == 0 ? "" : " on \(getShortWeekday(from: act.weekday))")")
                            Text(act.createdAt, style: .date).font(.footnote).foregroundColor(.gray)
                                
                            }
                             
                        }.listStyle(.plain)
                    }
                }
                
                
                        
                }.navigationBarHidden(true)
                    .navigationBarTitle(Text(""))
                }.navigationViewStyle(.stack)

        }
    }



