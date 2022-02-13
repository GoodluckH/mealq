//
//  CalendarBadge.swift
//  mealq
//
//  Created by Xipu Li on 1/12/22.
//

import SwiftUI

struct CalendarBadge: View {
    var specificDate: Date?
    var weekday: Int
    
    var body: some View {
        
        if let specificDate = specificDate {
            VStack{
            ZStack (alignment: .top) {

            RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                             style: .continuous)
                .foregroundColor(Color("QueryLoaderStartingColor"))
                .overlay{
                    Text(getDayComponent(from: specificDate))
                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 20))
                        .foregroundColor(Color("MyPrimary"))
                        .offset(y: UIScreen.main.bounds.width / 25 / 2)
                              }
                        
            

               Rectangle()
                .fill(getWeekdayColor(from: weekday))
                .frame(minHeight: UIScreen.main.bounds.width / 25)
                .aspectRatio(10/1, contentMode: .fit)
                .overlay {
                    Text(getMonthComponent(from: specificDate))
                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 27))
                        .foregroundColor(weekday == 1 ? Color("QueryLoaderStartingColor") : Color("MyPrimary"))
                }
                .clipped()
               
             


        }
            
        }
            .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
            .frame(maxWidth: UIScreen.main.bounds.width / 10, maxHeight: UIScreen.main.bounds.width / 10)
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: getWeekdayColor(from: weekday), radius: Constants.roundedRectShadowRadius/2, y: Constants.roundedRectShadowYOffset)
            .padding(Constants.tightStackSpacing * 2)
 
        } else {
            VStack{
                ZStack (alignment: .top) {

                RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                                 style: .continuous)
                    .foregroundColor(Color("QueryLoaderStartingColor"))
                    

                   Rectangle()
                    .fill(getWeekdayColor(from: weekday))
                    .frame(minHeight: 8)
                    .aspectRatio(10/1, contentMode: .fit)
                    .clipped()
                   
                   Text(getShortWeekday(from: weekday))
                        .font(Font.custom("Quicksand-SemiBold", size: weekday == 1 ? 12 : 14))
                    .foregroundColor(Color("MyPrimary"))
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
}

struct CalendarBadge_Previews: PreviewProvider {
    static var previews: some View {
        CalendarBadge(specificDate: Date(), weekday: 7)
    }
}
