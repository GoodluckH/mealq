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
    // @State private var scaleLottie: CGFloat = 1
    @FocusState private var isFocused: Bool
    @State var textHeight: CGFloat = 0
    @State var scrollViewOffset: CGFloat = 0

    init(meal: Meal) {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        UINavigationBar.appearance().tintColor = UIColor(Color("MyPrimary"))
        UITextView.appearance().textDragInteraction?.isEnabled = false
        UITextView.appearance().isScrollEnabled  = false
        UITextView.appearance().backgroundColor = .clear
        
        
        self.meal = meal
    }
    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = 35
        let maxHeight: CGFloat = 300
        
        if textHeight < minHeight {
            return minHeight
        }
        
        if textHeight > maxHeight {
            return maxHeight
        }
        
        return textHeight
    }
    
    
    var body: some View {
        VStack (spacing: 0) {
           if !messagesManager.messages.isEmpty {
                ScrollViewReader { reader in
                    ZStack{
                        
                        if scrollViewOffset >= 1000 && scrolled {
                            ToBottomMessageButton(reader: reader, lastMessageID: messagesManager.messages.last!.id).zIndex(1).transition(.opacity)
                        }
                  
                        ObservableScrollView {
                          
                           VStack{
                               
                               ForEach(Array(messagesManager.messages.enumerated()), id: \.offset) {i, msg in
                                   if i == 0 {
                                       Text(messagesManager.messages[0].timeStamp, style: .date).padding()
                                   } else {SmartTimeStamp(this: messagesManager.messages[i], lastDate: messagesManager.messages[i - 1])}
                                                
                                                
                                if i != messagesManager.messages.count - 1 &&
                                    messagesManager.messages[i + 1].senderID == msg.senderID {
                                    
                                    ChatRow(users: Array(meal.to.keys), message: msg, currentUser: sessionStore.localUser!, invitor: meal.from, showAvatar: false)
                                        
                                }
                                
                               else { ChatRow(users: Array(meal.to.keys), message: msg, currentUser: sessionStore.localUser!, invitor: meal.from, showAvatar: true) }
                            }.onChange(of: messagesManager.messages) { _ in
                                    withAnimation(.easeOut){reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)}
                            }
                            
                        
                               
                           }
                               
                            
                       
                        } onOffsetChange: { offset in
                            DispatchQueue.main.async {
                               withAnimation {scrollViewOffset = offset}
                            }
                            
                        }
                        .onAppear {UIScrollView.appearance().keyboardDismissMode = .interactive
                            reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)
                            scrolled = true
                        }
                        .onDisappear {scrolled = false }
                        
                    
        }
                    
                        
                }
                            
           } else {
           LottieView(fileName: "iceRocket")
               
               Text("why not be the first to break the ice?")
                   .foregroundColor(.gray)
               Spacer(minLength: UIScreen.main.bounds.height / 8)
                
        
           }
            
            VStack (spacing: 0){
               Divider()
               HStack {
                       ZStack (alignment: .topLeading){
                           
                           if messagesManager.messageContent.isEmpty && !isFocused {
                               Text("start a message")
                                   .foregroundColor(Color(UIColor.placeholderText))
                                   .padding(.horizontal, 13)
                                   .frame(minHeight: 35, alignment: .leading)
                                   
                           }
                           
                           DynamicHeightTextField(text: $messagesManager.messageContent, height: $textHeight)
                               .padding(.horizontal, 10)
                               .focused($isFocused)

                   
                   }
                           .background(Color.primary.opacity(0.06))
                           .clipShape(TextEditorBubble())
                           .frame(height: textFieldHeight)
             
           
                    
                
                    Button (action: {
                        messagesManager.sendMessage(from: sessionStore.localUser!, for: meal.id)
                    }) {
                        Image(systemName: "paperplane.fill")
                            .padding()
                            .font(.title3)
                            .foregroundColor(Color("QueryLoaderStartingColor"))
                            .frame(width: 35, height: 35)
                            .background(messagesManager.messageContent == "" ? .gray: Color("MyPrimary"))
                            .clipShape(Circle())
                    }
                    .disabled(messagesManager.messageContent == "")
                
            }.padding()
 
        }
        }
            .navigationBarTitle(meal.name, displayMode: .inline)
            .toolbar {
                
                NavigationLink (destination: MealDetailView(meal: meal).navigationBarTitle("")){
                    Image(systemName: "info.circle")
                        .foregroundColor(Color("MyPrimary"))
                       
                }
                
            }
    }
}





//struct ScrollViewOffsetPreferenceKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue = CGFloat.zero
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//            value += nextValue()
//
//    }
//}
