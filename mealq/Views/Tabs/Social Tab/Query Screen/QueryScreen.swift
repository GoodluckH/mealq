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
                        SectionView(usersCode: "query_friends", users: friendsManager.queryResult["friends"]!)
                    }
                    else if searchText.isEmpty {
                        SectionView(usersCode: "connected_friends",users: friendsManager.friends[1]!)
                    }
                    if !friendsManager.queryResult["others"]!.isEmpty {
                        SectionView(usersCode: "query_others", users: friendsManager.queryResult["others"]!)
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
                    ProgressView()
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

