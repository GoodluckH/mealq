//
//  MealChatRow.swift
//  mealq
//
//  Created by Xipu Li on 1/4/22.
//

import SwiftUI

struct MealChatRow: View {
    var meal: Meal
    var body: some View {
        HStack {
            VStack {
                Text(meal.name)
            }
            Spacer()
        }
        
    }
}










//
//struct MealChatRow_Previews: PreviewProvider {
//    static var previews: some View {
//        MealChatRow()
//    }
//}
