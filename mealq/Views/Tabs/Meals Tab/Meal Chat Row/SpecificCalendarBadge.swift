//
//  SpecificCalendarBadge.swift
//  mealq
//
//  Created by Xipu Li on 2/13/22.
//

import SwiftUI

struct SpecificCalendarBadge: View {
    @ObservedObject var mealDateManager = DatePickerViewModel.sharedDatePickerViewModel
    var specificDate: Date
    var weekday: Int
    var mealID: String
    
    
    var body: some View {
            HStack {
                Button (action: {
                    mealDateManager.date = specificDate
                    mealDateManager.showDatePicker = true
                    mealDateManager.currentMeal = mealID
                    Haptics.soft()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        mealDateManager.animate = true
                    }
                }) {
                    VStack{
                        ZStack (alignment: .top) {

                        RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                                         style: .continuous)
                            .foregroundColor(Color("QueryLoaderStartingColor"))
                            .overlay{
                                VStack {
                                    Text(getShortWeekday(from: weekday))
                                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 20))
                                    Text(specificDate, style: .time)
                                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 30))
                                }.foregroundColor(Color("MyPrimary"))
                                    .offset(y: UIScreen.main.bounds.width / 17 / 2)
                             
                                    
                                          }
             
                           Rectangle()
                            .fill(getWeekdayColor(from: weekday))
                            .frame(minHeight: UIScreen.main.bounds.width / 17)
                            .aspectRatio(10/1, contentMode: .fit)
                            .overlay {
                                Text("\(getMonthComponent(from: specificDate)) \(getDayComponent(from: specificDate))")
                                    .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 20))
                                    .foregroundColor(weekday == 1 ? Color("QueryLoaderStartingColor") : Color("MyPrimary"))
                            }
                            .clipped()
                           
             
                    }
                        
                }
                    .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 6)
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: getWeekdayColor(from: weekday), radius: Constants.roundedRectShadowRadius)
                    .padding(Constants.tightStackSpacing * 2)
                  
                        
                }
              
            }
           
            
            
        
        
           
    }
    
}

struct SpecificCalendarBadge_Previews: PreviewProvider {
    static var previews: some View {
        SpecificCalendarBadge(specificDate: Date(), weekday: 7, mealID: "")
    }
}
