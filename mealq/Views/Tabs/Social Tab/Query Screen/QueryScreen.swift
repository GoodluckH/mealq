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
    @FocusState.Binding var focusedField: Bool
    @EnvironmentObject var friendsManager: FriendsManager

    init(searchText: Binding<String>, focusedField: FocusState<Bool>.Binding){
        self._searchText = searchText
        self._focusedField = focusedField
    }
    
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
//            NavigationView{
            ScrollView {
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
            
         
//        }.frame(maxHeight:.infinity)
//            .navigationViewStyle(.stack) // to address LayoutConstraints error
//
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
                    .onTapGesture {focusedField = false}
                
                }
                
                }
            }
            .resignKeyboardOnDragGesture()
        }
    }
}

