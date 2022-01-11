//
//  MealChatRow.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct MealChatRow: View {
    var meal: Meal
    @EnvironmentObject var sessionStore: SessionStore
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: Constants.tightStackSpacing) {
                Text(getMealName(from: meal)).font(.headline).fontWeight(.bold).lineLimit(1)
                RowProfilePicView(meal: meal)
                MealTimeStamp(timeStamp: meal.createdAt)
            }
            Spacer()
        }
    }
    
    private func getMealName(from meal: Meal) -> String {
        let me = sessionStore.localUser!
        if meal.name == Constants.defaultMealName {
            var invitedParticipants: [String] = Array(meal.to.keys).filter{$0 != me}.map{$0.fullname}
            if meal.from != me {invitedParticipants.append(meal.from.fullname)}
            return "meal with " + invitedParticipants.joined(separator: ", ")
        } else {return meal.name}
    }
                
                
        
}










//
//struct MealChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        MealChatRow()
//    }
//}
