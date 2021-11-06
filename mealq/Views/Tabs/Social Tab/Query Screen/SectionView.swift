//
//  SectionView.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct SectionView: View {
    private var headerText: String {
        get {
            switch usersCode {
            case "query_others":
                return "Other People"
            default:
                return "My Friends"
            
            }
        }
    }
    var usersCode: String
    var users: [User]
    
    @EnvironmentObject var friendsManager: FriendsManager

    var body: some View {
        Section(header: SectionHeader(headerText: headerText)) {
            ForEach(users, id: \.id) { user in
               
                NavigationLink(destination: UserProfileView(user: user))
                    {
                        HStack {
                            ProfilePicView(picURL: user.thumbnailPicURL)
                                .onAppear{friendsManager.getFriendsFrom(user: user.id)}
                            .frame(width: 35, height: 35, alignment: .leading)
                            Text(user.fullname)
                            Spacer()
                    }
                }
                .foregroundColor(.black)
                .padding(.horizontal)
            }
        }
    }
}

