//
//  QueryScreen.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI
import ActivityIndicatorView


struct QueryScreen: View {
    @Binding var searchText: String
    @EnvironmentObject var friendsManager: FriendsManager
    @State var isDragging = false

    var drag: some Gesture {
        DragGesture(minimumDistance: 100)
            .onChanged { _ in
                self.isDragging = true
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
            .onEnded { _ in self.isDragging = false }
    }
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                ScrollView ([.vertical], showsIndicators: false){
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        if !friendsManager.queryResult["friends"]!.isEmpty {
                            SectionView(headerText: "My Friends", users: friendsManager.queryResult["friends"]!)
                        }
                        else if searchText.isEmpty {
                            if friendsManager.friends.isEmpty {
                                SectionView(headerText: "You don't have any friend... yet", users: [MealqUser]())
                            }
                            else {
                                SectionView(headerText: "My Friends", users:friendsManager.friends)
                            }
                        }
                        if !friendsManager.queryResult["others"]!.isEmpty {
                            SectionView(headerText: "Other People", users: friendsManager.queryResult["others"]!)
                        }
                            
                    }
                    .frame(alignment: .topLeading)
                }
                #warning("TODO: pan gesture to extend the pop gesture recognizer area: https://stackoverflow.com/questions/32914006/swipe-to-go-back-only-works-on-edge-of-screen/60598558#60598558")

            if !searchText.isEmpty &&
                friendsManager.queryResult["friends"]!.isEmpty &&
                friendsManager.queryResult["others"]!.isEmpty {
                if friendsManager.resolvingQuery {
                    ActivityIndicatorView(isVisible: .constant(true), type: .gradient([Color("QueryLoaderStartingColor"), .primary]))
                        .frame(width: geometry.size.width/12, height: geometry.size.width/12)
                        
                }else{
       
                    NoMatchView(searchText: $searchText).padding()
                    .environmentObject(friendsManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background()
                    .onTapGesture{
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    }
                }
                
                }
            }
            .gesture(drag)
   
            
           //.resignKeyboardOnDragGesture()
        }
    }
}

