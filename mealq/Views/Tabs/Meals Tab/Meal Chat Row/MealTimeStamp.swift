//
//  MealTimeStamp.swift
//  mealq
//
//  Created by Xipu Li on 1/10/22.
//

import SwiftUI

struct MealTimeStamp: View {
    var timeStamp: Date
    var body: some View {
        if let date = getTimeStampBetween(lastDate: Date(), and: timeStamp) {
            HStack(spacing: 5) {
                Text("created:")
                if date == "FULLDATE" {
                    Text(timeStamp, style: .date)
                }
                else  {
                    Text(date)
                }
                Text(timeStamp, style: .time)
            }
            .font(.custom("Quicksand-Medium", size: 12))
        }
    }
    
}

// ISSUE: when in MessageView, the userprofile pic pops out itself when clicked on profile pics
