//
//  AlertButton.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct AlertButton: View {
    @EnvironmentObject var friendsManager: FriendsManager
    @State var showNavLinkView = false
    var body: some View {
        NavigationLink(destination: FriendRequestsView(showNavLinkView: $showNavLinkView)
                            .navigationBarTitle("")
                            .navigationBarHidden(true), isActive: $showNavLinkView) {
        if friendsManager.pendingFriends.isEmpty {
                Image(systemName: "bell")
                    .onTapGesture{showNavLinkView = true}
                    .customFont(name: "Quicksand-SemiBold", style: .title2)
                    .foregroundColor(.primary)
                    
            } else  {
                Image(systemName: "bell.badge.fill")
                    .onTapGesture{showNavLinkView = true}
                    .customFont(name: "Quicksand-SemiBold", style: .title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, Color("MyPrimary"))
            }
        }
 
    }
}

















struct AlertButton_Previews: PreviewProvider {
    static var previews: some View {
        AlertButton().environmentObject(FriendsManager())
    }
}
