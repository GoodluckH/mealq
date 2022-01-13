//
//  CalendarBadge.swift
//  mealq
//
//  Created by Xipu Li on 1/12/22.
//

import SwiftUI

struct CalendarBadge: View {
    var weekday: Int
    var body: some View {
        
        
        VStack{
            ZStack (alignment: .top) {

            RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                             style: .continuous)
                .foregroundColor(.white)
                

               Rectangle()
                .fill(getWeekdayColor(from: weekday))
                .frame(minHeight: 8)
                .aspectRatio(10/1, contentMode: .fit)
                .clipped()
               
               Text(getShortWeekday(from: weekday))
                .font(Font.custom("Quicksand-SemiBold", size: 14))
                .foregroundColor(.black)
                .offset(y: 9)


        }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
        .frame(maxWidth: 30, maxHeight: 30)
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: getWeekdayColor(from: weekday), radius: Constants.roundedRectShadowRadius/2, y: Constants.roundedRectShadowYOffset)
        .padding(Constants.tightStackSpacing * 2)
            
    }
     

}

struct CalendarBadge_Previews: PreviewProvider {
    static var previews: some View {
        CalendarBadge(weekday: 2)
    }
}
