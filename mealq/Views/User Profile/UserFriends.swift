//
//  UserFriends.swift
//  mealq
//
//  Created by Xipu Li on 2/7/22.
//


import SwiftUI

struct UserFriends: View {
    @Binding var showSearchFriendSheet: Bool
    @State var searchText = ""
    var friends: [MealqUser]
    
    
    init(showSearchFriendSheet: Binding<Bool>, friends: [MealqUser]) {
        self._showSearchFriendSheet = showSearchFriendSheet
        self.friends = friends
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CustomSearchBar(searchText: $searchText, showNavLinkView: .constant(false), staticSearch: true)
                    .padding(.vertical)
                    .onChange(of: searchText) { queryText in
                        if queryText == " " {searchText = ""}
                    }
            
                ScrollView {
                    ForEach(friends.filter { friend in
                        if searchText == "" {return true}
                        else {return friend.fullname.contains(searchText)}
                    }, id: \.id) { friend in
                    VStack {
                        NavigationLink(destination: UserProfileView(user: friend)) {
                            HStack {
                                ProfilePicView(picURL: friend.normalPicURL)
                                    .frame(width: UIScreen.main.bounds.width / picSizeDivisor, height: UIScreen.main.bounds.width / picSizeDivisor)
                                Text(friend.fullname)
                                Spacer()

                            }.padding(.horizontal).foregroundColor(Color("MyPrimary"))
                           
                        }
                        Divider().padding(.leading).padding(.leading, UIScreen.main.bounds.width / picSizeDivisor)
  
                    }
                }

            }
            .navigationBarTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSearchFriendSheet = false
                    }) {
                        Text("Cancel")
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            }
        }

    }
    
    
    private let picSizeDivisor: CGFloat = 8
}


