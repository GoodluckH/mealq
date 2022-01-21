//
//  MealChatRow.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct MealChatRow: View {
    @Binding var meal: Meal
    @EnvironmentObject var sessionStore: SessionStore
   // @State private var isMessageViewed = false
    
    init(meal: Binding<Meal>) {
        self._meal = meal
    }

    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: Constants.tightStackSpacing) {
                HStack {
                    if meal.unreadMessages != 0 {
                        Text("\(meal.unreadMessages)")
                            .padding(.horizontal, Constants.tightStackSpacing * 3)
                            .foregroundColor(.white)
                            .background(.red)
                            .clipShape(Capsule())                            
                    }
                Text(getMealName(from: meal))
                    .customFont(name: "Quicksand-Bold", style: .headline, weight: meal.unreadMessages == 0 ? .semibold : .bold)
                    .lineLimit(1)
                }
                
                        
                Text(meal.recentMessageContent == "" ?  " " : meal.sentByName == "" ? "🎉 \(meal.recentMessageContent)" : "\(meal.sentByName): \(meal.recentMessageContent)")
                    .customFont(name: "Quicksand-SemiBold", style: .subheadline, weight: meal.unreadMessages != 0 ?  .bold : .semibold)
                    .foregroundColor(meal.unreadMessages == 0 ? .gray : Color("MyPrimary"))
                    .lineLimit(3)
                    .padding(.vertical, Constants.tightStackSpacing)
                        
                    
                  
                
                RowProfilePicView(meal: meal)
                // MealTimeStamp(timeStamp: meal.createdAt)
                
            }
            
            Spacer()
            if meal.weekday != 0 {
                CalendarBadge(weekday: meal.weekday)
            }
            
        }
        .padding(.vertical, Constants.tightStackSpacing * 2)
        
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
