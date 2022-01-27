//
//  SearchScreen.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct SearchScreen: View {
    @State private var searchText = ""
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    @EnvironmentObject var sessionStore: SessionStore
    @Binding var showNavLinkView: Bool
    var body: some View {
        
            VStack{
                CustomSearchBar(searchText:$searchText, showNavLinkView: $showNavLinkView)
                        .padding(.top)
                        .onChange(of: searchText) { queryText in
                            if queryText == " " {searchText = ""}
                            else {friendsManager.queryString(of: searchText, currentUserId: sessionStore.localUser!.id)}
                        }
             
                
                    QueryScreen(searchText: $searchText)
                        // We need to do this so that our view clears the previous search result
                        .onAppear{
                            if searchText == " " {searchText = ""}
                            else {friendsManager.queryString(of: searchText, currentUserId: sessionStore.localUser!.id)}
                        }
              
               
            }.navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
    }
}

