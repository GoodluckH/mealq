//
//  SectionView.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct SectionView: View {
    var headerText: String 
    var users: [MealqUser]
    
    @EnvironmentObject var friendsManager: FriendsManager

    var body: some View {
        Section(header: SectionHeader(headerText: headerText)) {
            ForEach(users, id: \.id) { user in
               
                NavigationLink(destination: UserProfileView(user: user)) {
                        HStack {
                            ProfilePicView(picURL: user.thumbnailPicURL)
                            .frame(width: 35, height: 35, alignment: .leading)
                            Text(user.fullname)
                                .foregroundColor(Color("MyPrimary"))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

