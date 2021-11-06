//
//  SocialView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct SocialView: View {
    @State private var searchText = ""
    @State private var showSearchScreen = false
    
    @StateObject var friendsManager = FriendsManager()
    @FocusState private var focusedField: Bool
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationView{
            VStack{
                    CustomSearchBar(searchText:$searchText, showSearchScreen: $showSearchScreen, focusedField: $focusedField)
                            .padding(.top)
                            .onChange(of: searchText) { queryText in
                                if queryText == " " {searchText = ""}
                                else {friendsManager.queryString(of: queryText)}
                            }
                
                ZStack {
                    if showSearchScreen {
                        QueryScreen(searchText: $searchText, focusedField: $focusedField)
                            .onAppear{
                                if searchText == " " {searchText = ""}
                                else {friendsManager.queryString(of: searchText)}
                                friendsManager.fetchData()
                            }
                            .transition(.move(edge: .bottom))
                    } else {
                        /// Todo
                        Text("no friend activity to display")
                            .frame(maxHeight: geometry.size.height, alignment: .top)
                            .ignoresSafeArea(.keyboard)
                        }
                }
                
        }
                    .navigationBarHidden(true)
                    .navigationBarTitle(Text(""))

            }
        }.environmentObject(friendsManager)

    }
}


struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
