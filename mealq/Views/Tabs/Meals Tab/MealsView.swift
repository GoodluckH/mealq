//
//  MealsView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct MealsView: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var showMealButton: ShowMealButton

    @State private var searchText = ""
    @State private var showMessageView = false
    @State private var lastVisitedMealID = ""
     var body: some View {
         NavigationView{
             VStack{
                 HStack {
                 Text("meals").customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                 Spacer()
                    SearchButton()
                 }.padding()
                 
                 HStack{
                      
                     if mealsManager.acceptedMeals.isEmpty{
                         // TODO: make this pretty
                      Text("you have no accepted meals for now").frame(maxHeight:.infinity, alignment: .top)
                     }
                     else {
                      List(mealsManager.acceptedMeals) { meal in
                          NavigationLink (destination:
                                            MessageView(meal: meal)
                                            .onAppear{
                              messagesManager.fetchMessages(from: meal.id)
                              showMealButton.showMealButton = false
                          }.onDisappear {
                              if lastVisitedMealID != meal.id {
                                  messagesManager.messages = [Message]()
                              }
                              lastVisitedMealID = meal.id
                              showMealButton.showMealButton = true
                          }
                          ){ MealChatRow(meal: meal) }
                          
                              
                      }.listStyle(.plain)
                 }
             }
         }.navigationBarTitle("").navigationBarHidden(true)
    
               
         
        }.navigationViewStyle(.stack)
           
   
             
         
     }
}





























//
//
//
//
//
//
//
//
//
//struct MealsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MealsView()
//    }
//}
