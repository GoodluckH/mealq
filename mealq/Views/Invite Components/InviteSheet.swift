//
//  InviteSheet.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import Introspect


struct InviteSheet: View {
    @State var selectedDate: Int?
    @State var mealName = ""
    
    @Binding var showSheet: Bool
    @State var showSearchFriendSheet: Bool = false
    @State var showMainContent: Bool = true
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @EnvironmentObject var mealsManager: MealsManager
    
    var body: some View {
        if mealsManager.sendingMealRequest == .done {
            LottieView(fileName: "colorfulCheckmark", loopMode: .playOnce, speed: 1.5)
                .task {
                    showMainContent = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                        if mealsManager.sendingMealRequest == .done {
                            showSheet = false
                            mealsManager.sendingMealRequest = .idle                            
                        }
                    }
                }
                
        }
        else if showMainContent && mealsManager.sendingMealRequest == .idle ||
                    mealsManager.sendingMealRequest == .loading {
           ScrollView ([], showsIndicators: false) { // pass in an empty set to disable the scrolling
            VStack {
                Header(mealName: $mealName, selectedFriends: friendsManager.selectedFriends).padding(.top).padding(.top)
                FakeSearchBar().shadow(color: .gray, radius: searchBarShadowRadius, y: searchBarShadowYOffset)
                    .onTapGesture {
                        showSearchFriendSheet = true
                        friendsManager.changedFriendSelection = false
                    }
                    .fullScreenCover(isPresented: $showSearchFriendSheet) {
                        SearchAndSelectFriends(showSearchFriendSheet: $showSearchFriendSheet)
                    }
                    
                
                
                
                // Friends selection
                HStack{
                    if friendsManager.friends.isEmpty {Text("no friends yet; search to add more").bold()}
                    else {
                        HStack {
                            Text("tap to select friends (up to 10)").bold()
                            Spacer()
                            
                            if friendsManager.selectedFriends.count > 0 {
                                Button (action: {friendsManager.selectedFriends = []}) {
                                Text("Reset")
                            }
                                
                            }
                        }
                        
                        
                    }
                    Spacer()
                }.padding(.horizontal).offset(y: 16)
                FriendSelection()
                
                
                
                // Date selection
                HStack{Text("tap to select a date (optional)").bold(); Spacer()}.padding(.horizontal).offset(y: 16)
                DateSelection(selectedDate: $selectedDate)
                
                
                // Send invite!
                VStack{
                    SendInviteButton(selectedFriends: friendsManager.selectedFriends, selectedDate: selectedDate, mealName: mealName, showSheet: $showSheet)
                        .padding(.top)
                    Spacer()
                    
                }
      
            } // VStack
            .introspectViewController{vc in if let sheet = vc.sheetPresentationController {sheet.prefersGrabberVisible = true}}
            .gesture(drag)
            
        }.onTapGesture {UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)}
           
       } //else
        

    }
    
    
    private let searchBarShadowRadius: CGFloat = 5
    private let searchBarShadowYOffset: CGFloat = 2
    
    
    @State var isDragging = false
    var drag: some Gesture {
        DragGesture(minimumDistance: 50)
            .onChanged { _ in
                self.isDragging = true
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
            .onEnded { _ in self.isDragging = false }
    }

}










struct Header: View {
    @Binding var mealName: String
    @FocusState private var focused: Bool
    var selectedFriends: [MealqUser]
    
    
    var body: some View {
        HStack {
            TextField("", text: $mealName)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .accentColor(Color("MyPrimary"))
                .placeholder("meal name", when: mealName.isEmpty, textColor: (mealName.isEmpty && focused) ? .gray : .primary)
                .introspectTextField {text in text.becomeFirstResponder()}
                .focused($focused)
                .frame(alignment: .leading)
                .font(.largeTitle.weight(.black))
                .minimumScaleFactor(0.1)
        }
        .padding()
        
    }
}










struct SendInviteButton: View {
    var selectedFriends: [MealqUser]
    var selectedDate: Int?
    var mealName: String
    @State var showAlert: Bool = false
    @Binding var showSheet: Bool
    
    @EnvironmentObject var mealsManager: MealsManager
    @EnvironmentObject var sessionStore: SessionStore
    var body: some View {
            VStack{
                Button(action:{
                mealsManager.sendMealRequest(to: selectedFriends, from: sessionStore.localUser!, on: selectedDate, mealName: mealName)
           
            }) {
                
                ZStack {
                    Capsule()
                        .fill(selectedFriends.isEmpty ? .gray : Color("MyPrimary"))
                        .shadow(color: .gray, radius: shadowRadius, y: shadowYOffset)
                        .padding()
                        .frame(width: rectMaxWidth, height: rectMaxHeight, alignment: .center)
                        
                    
                    if mealsManager.sendingMealRequest == .idle {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color("QueryLoaderStartingColor"))
                            .font(.largeTitle.weight(.black))

                    } else if mealsManager.sendingMealRequest == .loading {
                        LottieView(fileName: "rainbowLoader").frame(maxHeight: rectMaxHeight * 0.9, alignment: .center)
                    } else if mealsManager.sendingMealRequest == .error {
                        LottieView(fileName: "error", loopMode: .playOnce)
                            .onTapGesture{showAlert = true}
                            .alert("Something went wrong", isPresented: $showAlert) {
                                Button("Cancel", role: .cancel) {showSheet = false}
                                Button("Retry") {
                                    mealsManager.sendMealRequest(to: selectedFriends, from: sessionStore.localUser!, on: selectedDate, mealName: mealName)
                                }
                            }
                    }
                    
                } // zstack

            }
            .disabled(selectedFriends.isEmpty)
                
            }
    }
                    
        
    private let cornerRadius: CGFloat = 10
    private let shadowRadius: CGFloat = 7
    private let shadowYOffset: CGFloat = 1
    private let rectMaxWidth: CGFloat = 200
    private let rectMaxHeight: CGFloat = 90
}

























//
//struct InviteSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        InviteSheet()
//            .preferredColorScheme(.light)
//    }
//}
