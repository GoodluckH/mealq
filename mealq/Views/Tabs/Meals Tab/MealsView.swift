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
    
    private func activeChatBinding(id: String?) -> Binding<Bool> {
        .init {
            activeChat != nil && activeChat == id
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
                                 Button(action: {activeChat = meal.id}) {
                                     MealChatRow(meal: $meal)
                                 }
                                }

                     }.listStyle(.plain)
                 }
                 }.background {
                     NavigationLink("", isActive: activeChatBinding(id: activeChat)) {
                         if let activeChat = activeChat {
                             MessageView(meal: bindingForChat(id: activeChat).wrappedValue)
                                 .onAppear{
                                   messagesManager.fetchMessages(from: bindingForChat(id: activeChat).wrappedValue.id)
                                   showMealButton.showMealButton = false
                                   }.onDisappear {
                                       if lastVisitedMealID != bindingForChat(id: activeChat).wrappedValue.id {
                                           messagesManager.messages = [Message]()
                                       }
                                       lastVisitedMealID = bindingForChat(id: activeChat).wrappedValue.id
                                       showMealButton.showMealButton = true
                                   }
                             
                         } else {
                             EmptyView()
                         }
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
