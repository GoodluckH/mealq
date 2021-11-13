//
//  AlertButton.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct AlertButton: View {
    @EnvironmentObject var friendsManager: FriendsManager
    var body: some View {
        NavigationLink(destination: FriendRequestsView()
                            .navigationBarTitle("")
                            .navigationBarHidden(true)) {
            if friendsManager.pendingFriends.isEmpty {
                Image(systemName: "bell")
                    .customFont(name: "Quicksand-SemiBold", style: .title2)
                    .foregroundColor(.primary)
                    
            } else  {
                Image(systemName: "bell.badge.fill")
                    .customFont(name: "Quicksand-SemiBold", style: .title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, .primary)
            }
        }
 
    }
}

















struct AlertButton_Previews: PreviewProvider {
    static var previews: some View {
        AlertButton().environmentObject(FriendsManager())
    }
}
