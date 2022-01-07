//
//  MealDetailView.swift
//  mealq
//
//  Created by Xipu Li on 1/1/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MealDetailView: View {
    var meal: Meal
    @State private var showBigPic = false
    @EnvironmentObject var sessionStore: SessionStore
    
    init(meal: Meal) {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        self.meal = meal
    }
    
    var body: some View {
        VStack {
        
            ProfilePicView(picURL: meal.from.normalPicURL)
                .onTapGesture{showBigPic = true}
                .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                .navigationBarTitle(Text(meal.name), displayMode: .inline)
                .sheet(isPresented: $showBigPic) {
                    BigUserPicView(picURL: URL(string: ((meal.from.thumbnailPicURL?.absoluteString) != nil) ? meal.from.thumbnailPicURL!.absoluteString + "?width=1000&height=1000" : ""))
                }
                  
            Text(meal.from.fullname)
                .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
            
            MealControlButtons(userStatus: meal.to, mealID: meal.id)
            
            ScrollView{
                LazyVStack(pinnedViews: [.sectionHeaders]){
                    Section(header: SectionHeader(headerText: "other invitees")) {
                        ForEach(meal.to.keys.filter{$0 != sessionStore.localUser!}.sorted{$0.fullname > $1.fullname}, id: \.self) { user in
                        
                        HStack {
                            NavigationLink(destination: UserProfileView(user: user)){
                                ProfilePicView(picURL: user.normalPicURL)
                                    .frame(width: ProfilePicStyles.profilePicWidth / 2.5, height: ProfilePicStyles.profilePicHeight / 2.5)
                                Text(user.fullname).foregroundColor(Color("MyPrimary"))
                                
                            }
                            Spacer()
                            Text(meal.to[user]!)
                        }.padding(.horizontal)
                        
                    }
                    }
                }
               }
            
            Spacer()

        }
        .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            
            
    }
}





















//struct MealDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealDetailView()
//    }
//}
