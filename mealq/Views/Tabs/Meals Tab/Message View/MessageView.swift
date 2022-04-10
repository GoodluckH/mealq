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
    @Binding var meal: Meal?
    @State var fromNoti: Bool
    let lastMealID: String
    
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var sessionStore: SessionStore
    
    @ObservedObject var keyboard = KeyboardResponder()
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrolled = false
    @State private var reFocus = false
    @State private var textHeight: CGFloat = 0
    @State private var lastTextHeight: CGFloat = 0
    @State private var showClickToBottomButton: Bool = false
    @State private var scrollView: UIScrollView? = nil
    @State private var firstMsgToFocus: String? = nil
    @State private var showingDetailedMeal = false
    @State private var showingAlert = false
    
    @FocusState private var isFocused: Bool
    
    
    init(meal: Binding<Meal?>, fromNoti: Bool, lastMealID: String) {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Quicksand-Bold", size: 20)!]
        UINavigationBar.appearance().tintColor = UIColor(Color("MyPrimary"))
        
     
    
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color("QueryLoaderStartingColor"))
        
        
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            
            
        
        
        
        UITextView.appearance().textDragInteraction?.isEnabled = false
        UITextView.appearance().isScrollEnabled  = false
        UITextView.appearance().backgroundColor = .clear
        
        self._meal = meal
        self._fromNoti = State(initialValue: fromNoti)
        self.lastMealID = lastMealID
        
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
     if let meal = meal {
         VStack (spacing: 0) {
            // Displays all messaegs if the current meal session has messages
            if !messagesManager.messages.isEmpty {
                ScrollViewReader { reader in
                    ScrollView (messagesManager.fetchingMoreMessages == .loading ? [] : .vertical) {
                        VStack{
        
                            ForEach(Array(messagesManager.messages.enumerated()), id: \.offset) {i, msg in
                                if let date = getTimeStampBetween(lastDate: i == 0 ? Date() : messagesManager.messages[i-1].timeStamp, and: msg.timeStamp, mandatory: i == 0) {
                                        ChatTimeStamp(date: date, timeStamp:msg.timeStamp)
                                    }
                                    
                                
                                            
                                ChatRow(users: Array(meal.to.keys), message: msg, currentUser: sessionStore.localUser!,
                                        invitor: meal.from, showAvatar: !(i != messagesManager.messages.count - 1 && messagesManager.messages[i + 1].senderID == msg.senderID)).id(msg.id)
                                    .onAppear{
                                        if meal.recentMessageID == msg.id && messagesManager.messages.last?.id == msg.id {
                                            // TODO: Need to add a logic here, otherwise it will scroll down
                                            
                                            if meal.unreadMessages > 0 {
                                                mealsManager.setMessageAsViewed(mealID: meal.id, count: meal.unreadMessages)
                                                withAnimation(.easeOut.speed(3)){reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)}
                                            }
                                        }
                                        if reFocus {
                                            reFocus = false
                                            withAnimation(.easeOut.speed(3)){reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)}
                                        }
                                    }.contextMenu {
                                        Button(action: {showingAlert = true}) {
                                            Text("Report")
                                        }
                                    }.alert("Report Content", isPresented: $showingAlert) {
                                        Button("Yes", role: .destructive) {}
                                    } message: {
                                        Text("Is this message inappropriate? We will review this report within 24 hrs and if deemed inappropriate the message will be removed within that timeframe. We will also take actions against it's sender.")
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
                            
                        }.background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("frameLayer")).origin.y)
                        })
            
                        }
                        .overlay(ExpandableInfo(meal: $meal).offset(y: -(Constants.tightStackSpacing * 6)), alignment: .top)
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
                        .coordinateSpace(name: "frameLayer").onPreferenceChange(ViewOffsetKey.self) {
                            if $0 < 0 {
                                if messagesManager.fetchingMessages == .idle {
                                    firstMsgToFocus = messagesManager.messages.first?.id ?? nil
                                    messagesManager.fetchMoreMessages()
                                }
                            }
                        }
                        .onReceive(messagesManager.$fetchingMoreMessages) { status in
                            if status == .done {
                                if let id = firstMsgToFocus {
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        reader.scrollTo(id, anchor: .top)
                                        messagesManager.fetchingMoreMessages = .idle
                                    }
                                   
                                }
                            }
                            
                        }
                        .onAppear {
                            UIScrollView.appearance().keyboardDismissMode = .interactive
                            if !scrolled || (fromNoti && lastMealID == meal.id) {
                                fromNoti = false
                                reader.scrollTo(messagesManager.messages.last!.id, anchor: .bottom)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    scrolled = true
                                }
                            }
                        }
                        .introspectScrollView { scrollView in
                            self.scrollView = scrollView
                        }
                        .padding(.top, Constants.tightStackSpacing * 6)
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
                       
             
                    // Send button
                    Button (action: {
                        messagesManager.sendMessage(from: sessionStore.localUser!, for: meal)
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
 
        }.animation(.easeOut.speed(3), value: textHeight)
    }
        .onReceive(keyboard.$currentHeight) { height in
            
            if lastTextHeight == CGFloat(0) || !isFocused || textHeight < lastTextHeight {lastTextHeight = textHeight}
            if let _ = scrollView {
                if height > 0 && !isFocused && (keyboardHeight == 0 || messagesManager.messageContent == "") && !showingDetailedMeal  {
                    print("this is triggered!!")
                    self.scrollView!.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentOffset.y + height), animated: true)
                } else if isFocused && textHeight > lastTextHeight {
                    print("else if this is triggered!!")
                    self.scrollView!.setContentOffset(CGPoint(x: 0, y: self.scrollView!.contentOffset.y + textHeight - lastTextHeight), animated: true)
                    lastTextHeight = textHeight
                
                }
                
                keyboardHeight = height
            }
        }
        .navigationBarTitle("", displayMode: .inline)//messagesManager.fetchingMessages == .loading ? "loading..." : meal.name, displayMode: .inline)
        
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text("\(messagesManager.fetchingMessages == .loading ? "loading..." : meal.name)")
                    .font(Font.custom("Quicksand-Bold", size: 20))
            }
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink (destination: MealDetailView(meal: $meal, allowEdit: true)
                                                .onAppear { showingDetailedMeal = true }
                                                .onDisappear { showingDetailedMeal = false }
                                               
                ) {
                    Image(systemName: "info.circle").foregroundColor(Color("MyPrimary"))
            }
            }
            
          

            
        }
    }
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
 
    }
}
