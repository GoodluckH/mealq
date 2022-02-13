//
//  RowProfilePicView.swift
//  mealq
//
//  Created by Xipu Li on 1/10/22.
//

import SwiftUI

struct RowProfilePicView: View {
    @Binding var meal: Meal
    @EnvironmentObject var sessionStore: SessionStore
    var body: some View {
        //ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .top, spacing: Constants.tightStackSpacing){
                
                if let localUser = sessionStore.localUser {
                    ForEach(getAllMealParticipantsExSelf(to: Array(meal.to.keys), from: meal.from, me: localUser), id: \.self) { user in
                    VStack (spacing: Constants.tightStackSpacing){
                        ProfilePicView(picURL: user.normalPicURL)
                        .frame(width: UIScreen.main.bounds.width / 17, height: UIScreen.main.bounds.width / 17)
                        Capsule()
                            .foregroundColor(getColoredStatus(from: meal.to, for: user))
                            .frame(width: UIScreen.main.bounds.width / 25, height: UIScreen.main.bounds.width / 100)
                            
                    }
                }    
                }
                Spacer()
            }
        //}
    }
    
    private func getColoredStatus(from invitees: [MealqUser: String], for user: MealqUser) -> Color {
        if let status = invitees[user] {
            if status == "pending" {return .yellow}
            if status == "accepted" {return .green}
            if status == "declined" {return .red}
        }
        return .green
    }
    
}
