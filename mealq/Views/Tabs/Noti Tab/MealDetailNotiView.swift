//
//  MealDetailView.swift
//  mealq
//
//  Created by Xipu Li on 1/1/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Introspect
import Lottie

struct MealDetailNotiView: View {
    var meal: Meal
    
    @State private var showBigPic = false
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var messagseManager: MessagesManager
    
    @State private var showAlert = false

    
    
    init(meal: Meal) {
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        self.meal = meal
    }
    
    var body: some View {
         ZStack{
             VStack {
        
            ProfilePicView(picURL: meal.from.normalPicURL)
                .onTapGesture{showBigPic = true}
                .frame(width: ProfilePicStyles.profilePicWidth, height: ProfilePicStyles.profilePicHeight)
                .sheet(isPresented: $showBigPic) {
                    BigUserPicView(picURL: URL(string: ((meal.from.thumbnailPicURL?.absoluteString) != nil) ? meal.from.thumbnailPicURL!.absoluteString + "?width=1000&height=1000" : ""))
                }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack (spacing: Constants.tightStackSpacing) {
                                Text(meal.name).font(Font.custom("Quicksand-Bold", size: 20))
                        }
                    }
                }
                  
            Text(meal.from.fullname)
                .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
            
             MealControlButtons(userStatus: meal.to, meal: meal)
             
                 if let mealDate = meal.specificDate {
                     Text(mealDate, style: .timer)
                     Text(mealDate, style: .date)
                     Text(mealDate, style: .time)
                 } else {
                     Text("specific date is not set")
                 }
         
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
    
}



