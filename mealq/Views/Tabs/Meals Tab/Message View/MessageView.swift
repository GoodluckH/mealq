//
//  MessageView.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//
import Combine
import SwiftUI
import Introspect

struct MessageView: View {
    let meal: Meal
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var sessionStore: SessionStore
    
    @ObservedObject var keyboard = KeyboardResponder()
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrolled = false
    @State private var reFocus = false
    @State private var textHeight: CGFloat = 0
    @State private var showClickToBottomButton: Bool = false
    @State private var scrollView: UIScrollView? = nil
    
    @FocusState private var isFocused: Bool
   
    
    init(meal: Meal) {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        UINavigationBar.appearance().tintColor = UIColor(Color("MyPrimary"))
        UITextView.appearance().textDragInteraction?.isEnabled = false
        UITextView.appearance().isScrollEnabled  = false
        UITextView.appearance().backgroundColor = .clear
        
        self.meal = meal
    }
    
    
    var textFieldHeight: CGFloat {
        let minHeight: CGFloat = Constants.dynamicTextFieldMinHeight
        let maxHeight: CGFloat = Constants.dynamicTextFieldMaxHeight
        
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
            // Displays all messaegs if the current meal session has messages
            if !messagesManager.messages.isEmpty {
                ScrollViewReader { reader in
                    ScrollView {
                        VStack{
        
                            ForEach(Array(messagesManager.messages.enumerated()), id: \.offset) {i, msg in
                                if i != 0 {
                                    if let date = getTimeStampBetween(lastDate: messagesManager.messages[i-1].timeStamp, and: msg.timeStamp) {
                                        HStack{
                                            Text(date)
                                            if date != "FULLDATE" {
                                                Text(msg.timeStamp, style: .time)
                                            }
                                            
                                        }.padding()
                                    }
                                                        
                                }
                                            
                                ChatRow(users: Array(meal.to.keys), message: msg, currentUser: sessionStore.localUser!,
                                        invitor: meal.from, showAvatar: !(i != messagesManager.messages.count - 1 && messagesManager.messages[i + 1].senderID == msg.senderID)).id(msg.id)
                                    .onAppear{
                                        if reFocus {
                                            reFocus = false
                                            withAnimation(.spring()){reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)}
                                        }
                                    }
                                }
                            
                            GeometryReader { proxy -> Color in
                                DispatchQueue.main.async {
                                    let offset = proxy.frame(in: .named("frameLayer")).maxY
                                    withAnimation {if offset > 650 {showClickToBottomButton = true}
                                    else {showClickToBottomButton = false}}
                                    }
                                    return Color.clear
                                }.frame(width: 0, height: 0)
                            
                    }
            
                        }
                        .overlay(
                            VStack {
                                Spacer ()
                                HStack{
                                    Spacer()
                                    ToBottomMessageButton(reader: reader, lastMessageID: messagesManager.messages.last!.id)
                                        .scaleEffect(showClickToBottomButton && scrolled ? 1:0)
                                        .padding()
                                        .disabled(!(showClickToBottomButton && scrolled))
                                }
                            })
                        .coordinateSpace(name: "frameLayer")
                        .onAppear {
                            UIScrollView.appearance().keyboardDismissMode = .interactive
                            if !scrolled{
                                reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { scrolled = true }
                            }
                        }
                        .introspectScrollView { scrollView = $0 }
                }
                            
           }
            
            // Displays an animation if there's no message in this meal
            else if messagesManager.fetchingMessages == .idle {
               LottieView(fileName: "iceRocket")
               Text("why not be the first to break the ice?")
                   .foregroundColor(.gray)
               Spacer(minLength: UIScreen.main.bounds.height / 8)
           }
            
            // Displays nothing if the app is fetching messages
            else { Spacer()}
            
                        
            
            // Text bar for user inputs
            VStack (spacing: 0){
               Divider()
               HStack {
                   // Textfield
                   ZStack (alignment: .topLeading){
                       
                       // Placeholder text
                       if messagesManager.messageContent.isEmpty && !isFocused {
                           Text("start a message")
                               .foregroundColor(Color(UIColor.placeholderText))
                               .padding(.horizontal, 13)
                               .frame(minHeight: 36, alignment: .leading)

                       }

                       // Textfield
                       DynamicHeightTextField(text: $messagesManager.messageContent, height: $textHeight)
                           .padding(.horizontal, 10)
                           .focused($isFocused)
                   }
                       .background(Color.primary.opacity(0.06))
                       .clipShape(TextEditorBubble())
                       .frame(height: textFieldHeight)
                       .animation(.easeOut.speed(3), value: textHeight)
             
                    // Send button
                    Button (action: {
                        messagesManager.sendMessage(from: sessionStore.localUser!, for: meal.id)
                        reFocus = true
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
    .onReceive(keyboard.$currentHeight) { height in
        print(textHeight)
        if let _ = scrollView {
            if height > 0 && !isFocused && messagesManager.messageContent == ""  {
                self.scrollView!.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentOffset.y + height), animated: true)
            }
             
            keyboardHeight = height
        }
    }
    .navigationBarTitle(messagesManager.fetchingMessages == .loading ? "loading..." : meal.name, displayMode: .inline)
    .toolbar {
        NavigationLink (destination: MealDetailView(meal: meal).navigationBarTitle("")){
            Image(systemName: "info.circle")
                .foregroundColor(Color("MyPrimary"))
        }
    }
    
    }
}



//        .onReceive(keyboardHeight) { height in
//            print(height)
//        }
//        .onReceive(keyboardHeight) {height in
//            if height > 0 {
//                self.scrollView!.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentOffset.y + height), animated: true)
//            } else {
//                self.scrollView!.contentOffset.y = max(self.scrollView!.contentOffset.y - keyboardHeight, 0)
//            }

//            keyboardHeight = height
//
//        }
