//
//  SearchAndSelectFriends.swift
//  mealq
//
//  Created by Xipu Li on 2/4/22.
//

import SwiftUI

struct SearchAndSelectFriends: View {
    @ObservedObject var friendsManager = FriendsManager.sharedFriendsManager
    
    @Binding var showSearchFriendSheet: Bool
    private var initialStateOfSelectedFriends: Set<String>
    
    @State var searchText = ""
    
    init(showSearchFriendSheet: Binding<Bool>) {
        self._showSearchFriendSheet = showSearchFriendSheet
        self.initialStateOfSelectedFriends = Set<String>()
        if !FriendsManager.sharedFriendsManager.changedFriendSelection {
            FriendsManager.sharedFriendsManager.selectedFriends.forEach {self.initialStateOfSelectedFriends.insert($0.id)}
        }
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
                    ForEach(friendsManager.friends.filter { friend in
                        if searchText == "" {return true}
                        else {return friend.fullname.contains(searchText)}
                    }, id: \.id) { friend in
                    VStack {
                        Button(action: {
                            if !friendsManager.changedFriendSelection {
                                friendsManager.changedFriendSelection = true
                            }
                        
                            if let friendToRemove = friendsManager.selectedFriends.firstIndex(of: friend) {
                                friendsManager.selectedFriends.remove(at: friendToRemove)
                            } else {
                                friendsManager.selectedFriends.append(friend)
                            }
                        }) {
                            HStack {
                                ProfilePicView(picURL: friend.normalPicURL)
                                    .frame(width: UIScreen.main.bounds.width / picSizeDivisor, height: UIScreen.main.bounds.width / picSizeDivisor)
                                Text(friend.fullname)
                                Spacer()
                                if friendsManager.selectedFriends.contains(friend){
                                    Image(systemName: "checkmark")
                                }
                            }.padding(.horizontal)
                        }.foregroundColor(Color("MyPrimary"))
                        Divider().padding(.leading).padding(.leading, UIScreen.main.bounds.width / picSizeDivisor)
                    }
                }

            }
                    .navigationBarTitle("")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                showSearchFriendSheet = false
                            }) {
                                Text("Done")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                friendsManager.selectedFriends = friendsManager.friends.filter {initialStateOfSelectedFriends.contains($0.id)}
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







//struct SearchAndSelectFriends_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchAndSelectFriends()
//    }
//}
