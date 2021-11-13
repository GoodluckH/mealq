//
//  SearchScreen.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct SearchScreen: View {
    @State private var searchText = ""
    @EnvironmentObject var friendsManager: FriendsManager
    @FocusState.Binding var focusedField: Bool
    @Binding var showNavLinkView: Bool
    var body: some View {
        
            VStack{
                CustomSearchBar(searchText:$searchText, focusedField: $focusedField, showNavLinkView: $showNavLinkView)
                        .padding(.top)
                        .onChange(of: searchText) { queryText in
                            if queryText == " " {searchText = ""}
                            else {friendsManager.queryString(of: queryText)}
                        }
                HStack {
                
                    QueryScreen(searchText: $searchText, focusedField: $focusedField)
                        .onAppear{
                            if searchText == " " {searchText = ""}
                            else {friendsManager.queryString(of: searchText)}
                        }
                        .transition(.move(edge: .bottom))
                }
               
            }.navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
    }
}

//struct SearchScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchScreen().environmentObject(FriendsManager())
//    }
//}
