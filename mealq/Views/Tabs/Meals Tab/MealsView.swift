//
//  MealsView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct MealsView: View {
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var messagesManager: MessagesManager
    @ObservedObject var sharedMealVariables = MealVariables.sharedMealVariables

    @State private var searchText = ""
    @State private var showMessageView = false
    @State private var lastVisitedMealID = ""
    @State private var activeChat : String?
    @State private var fromNoti = false

    
    @ObservedObject private var sharedViewManager = ViewManager.sharedViewManager
    private func activeChatBinding(id: String?) -> Binding<Bool> {
        .init {
             return activeChat != nil && activeChat == id
        } set: { newValue in
            activeChat = newValue ? id : nil
        }
    }
    
    private func bindingForChat(id: String) -> Binding<Meal?> {
        .init {
            mealsManager.acceptedMeals.first(where: { $0.id == id })
        } set: { newValue in
            if newValue != nil {
                mealsManager.acceptedMeals = mealsManager.acceptedMeals.map { $0.id == id ? newValue! : $0 }
            }
            
            
        }
    }
    
     var body: some View {
         NavigationView{
             VStack{
                 HStack {
                 Text("meals").customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                 Spacer()
                    SearchButton()
                 }.padding()
                 
                 VStack{
                      
                     if mealsManager.acceptedMeals.isEmpty{
                         // TODO: make this pretty
                      Text("you have no accepted meals for now").frame(maxHeight:.infinity, alignment: .top)
                     }
                     else {
                         List() {
                             ForEach($mealsManager.acceptedMeals, id: \.id){ $meal in
                                 Button(action: {
                                     activeChat = meal.id
                                     fromNoti = false
                                 }) {
                                     MealChatRow(meal: $meal, showUnreadBadges: sharedMealVariables.showUnreadBadges)
                                 }
                                }

                     }.listStyle(.plain)
                 }
                 }.background {
                     NavigationLink("", isActive: activeChatBinding(id: activeChat)) {
                         if let activeChat = activeChat, let bindingMeal = bindingForChat(id: activeChat), let currentMeal = bindingForChat(id: activeChat).wrappedValue {
                             MessageView(meal: bindingMeal, fromNoti: fromNoti, lastMealID: lastVisitedMealID == "" ? activeChat : lastVisitedMealID)
                                 .onAppear{
                                     if lastVisitedMealID != activeChat {
                                         messagesManager.messages = [Message]()
                                         messagesManager.fetchMessages(from: currentMeal.id)
                                     }
                                     sharedMealVariables.showUnreadBadges = false
                                     sharedMealVariables.hideUnreadBadgesForMealID = currentMeal.id
                                     
                                     sharedViewManager.currentMealChatSession = activeChat
                                     lastVisitedMealID = activeChat
                                     sharedMealVariables.showMealButton = false

                                   }.onDisappear {
                                       if currentMeal.unreadMessages > 0 {
                                           mealsManager.setMessageAsViewed(mealID: currentMeal.id, count: currentMeal.unreadMessages)
                                       }
                                       sharedMealVariables.showUnreadBadges = true
                                       sharedMealVariables.hideUnreadBadgesForMealID = nil
                                       sharedMealVariables.showMealButton = true
                                   }
                             
                         } else {
                             EmptyView()
                         }
                     }
                 }
                 
                 
                 
                 
         }.navigationBarTitle("").navigationBarHidden(true).onReceive(sharedViewManager.$selectedMealSession) { mealID in
             if mealID != nil {
                 activeChat = mealID
                 //sharedViewManager.selectedMealSession = nil
                 messagesManager.messages = [Message]()
                 messagesManager.fetchMessages(from: mealID!)
                 lastVisitedMealID = mealID!
                 fromNoti = true
             }
             
         }
             
         }
             .navigationViewStyle(.stack)
             .ignoresSafeArea(edges: .top)
             
                
           
   
             
         
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
