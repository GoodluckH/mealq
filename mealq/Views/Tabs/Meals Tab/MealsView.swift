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
    
    private func bindingForChat(id: String) -> Binding<Meal> {
        .init {
            mealsManager.acceptedMeals.first { $0.id == id }!
        } set: { newValue in
            mealsManager.acceptedMeals = mealsManager.acceptedMeals.map { $0.id == id ? newValue : $0 }
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
                                     MealChatRow(meal: $meal)
                                 }
                                }

                     }.listStyle(.plain)
                 }
                 }.background {
                     NavigationLink("", isActive: activeChatBinding(id: activeChat)) {
                         if let activeChat = activeChat {
                             MessageView(meal: bindingForChat(id: activeChat).wrappedValue, fromNoti: fromNoti, lastMealID: lastVisitedMealID == "" ? activeChat : lastVisitedMealID)
                                 .onAppear{
                                     if lastVisitedMealID != activeChat {
                                         messagesManager.messages = [Message]()
                                     }
                                     messagesManager.fetchMessages(from: bindingForChat(id: activeChat).wrappedValue.id)
                                     sharedViewManager.currentMealChatSession = activeChat
                                     lastVisitedMealID = activeChat
                                     showMealButton.showMealButton = false

                                   }.onDisappear {
                                       showMealButton.showMealButton = true
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
