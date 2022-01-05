//
//  MessageView.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct MessageView: View {
    let meal: Meal
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var sessionStore: SessionStore
    
    @State private var scrolled = false
    @FocusState private var isFocused: Bool

    init(meal: Meal) {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        
        // For navigation bar background color
        let myColor = UIColor(Color("QueryLoaderStartingColor"))
        let semi = myColor.withAlphaComponent(0.5)
        UINavigationBar.appearance().backgroundColor = semi
        
        
        self.meal = meal
    }
    
    
    
    var body: some View {
        VStack (spacing: 0) {
            if !messagesManager.messages.isEmpty {
                ScrollViewReader { reader in
                    ScrollView  {
                        Text(messagesManager.messages[0].timeStamp, style: .date).padding()
                    
                        ForEach(messagesManager.messages) {msg in
                             ChatRow(users: Array(meal.to.keys), message: msg, currentUser: sessionStore.localUser!)
                                .onAppear {
                                    if msg.id == messagesManager.messages.last!.id && !scrolled {
                                        reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)
                                        scrolled = true
                                    }
                                }
                        }.onChange(of: messagesManager.messages) { _ in
                            reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)
                        }
                        
                    }.onAppear {
                        UIScrollView.appearance().keyboardDismissMode = .interactive
                    }
                    
                    HStack {
                        TextField("start a message", text: $messagesManager.messageContent)
                            .focused($isFocused)
                            .padding(.horizontal)
                            .frame(height: 35)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                   
                            
                        if messagesManager.messageContent != "" {
                            Button (action: {
                                messagesManager.sendMessage(from: sessionStore.localUser!, for: meal.id)
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                                    .foregroundColor(Color("QueryLoaderStartingColor"))
                                    .frame(width: 35, height: 35)
                                    .background(Color("MyPrimary"))
                                    .clipShape(Circle())
                            }
                        }
                    }.padding(.horizontal)
                        .padding(.bottom)
                    
                        
                }
            
            
                
            }
 
        
        }
            .navigationBarTitle(meal.name, displayMode: .inline)
            .toolbar {
                
                NavigationLink (destination: MealDetailView(meal: meal)){
                    Image(systemName: "info.circle")
                        .foregroundColor(Color("MyPrimary"))
                }
                
            }
    }
}








//
//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView()
//    }
//}
