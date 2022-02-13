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
    @State var showDetail = false
    @Namespace var nspace
    
    
    var body: some View {
        if showDetail {
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
                    Circle()
                        .fill(Color("QueryLoaderStartingColor"))
                        .shadow(color: getWeekdayColor(from: weekday), radius: Constants.roundedRectShadowRadius)
                        .overlay {
                        Image(systemName: "pencil")
                                .font(.title)
                                .foregroundColor(Color("MyPrimary"))
                    }.frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                        
                        
                        
                }.matchedGeometryEffect(id: "detail2", in: nspace)
                VStack{
                    ZStack (alignment: .top) {

                    RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                                     style: .continuous)
                        .foregroundColor(Color("QueryLoaderStartingColor"))
                        .overlay{
                            Text(specificDate, style: .time)
                                .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 20))
                                .foregroundColor(Color("MyPrimary"))
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
                       
         
                }.matchedGeometryEffect(id: "detail", in: nspace)
                    
            }
                .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
                .frame(maxWidth: UIScreen.main.bounds.width / 4, maxHeight: UIScreen.main.bounds.width / 8)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: getWeekdayColor(from: weekday), radius: Constants.roundedRectShadowRadius)
                .padding(Constants.tightStackSpacing * 2)
                .onTapGesture{
                    withAnimation {showDetail = false}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        mealDateManager.animate = false
                    }
                }
            }
           
            
            
        }
        
        else{
            Button (action: {
                Haptics.rigid()
                withAnimation
                {showDetail = true}
            }) {
            VStack{
            ZStack (alignment: .top) {

            RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                             style: .continuous)
                .foregroundColor(Color("QueryLoaderStartingColor"))
                .overlay{
                    Text(getDayComponent(from: specificDate))
                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 20))
                        .foregroundColor(Color("MyPrimary"))
                        .offset(y: UIScreen.main.bounds.width / 20 / 2)
                              }
                        
            

               Rectangle()
                .fill(getWeekdayColor(from: weekday))
                .frame(minHeight: UIScreen.main.bounds.width / 20)
                .aspectRatio(10/1, contentMode: .fit)
                .overlay {
                    Text(getShortWeekday(from: weekday))
                        .font(Font.custom("Quicksand-SemiBold", size:  UIScreen.main.bounds.width / 25))
                        .foregroundColor(weekday == 1 ? Color("QueryLoaderStartingColor") : Color("MyPrimary"))
                       
                }
                .clipped()
               
             


        }.matchedGeometryEffect(id: "detail", in: nspace)
                    .matchedGeometryEffect(id: "detail2", in: nspace)
            
        }
            .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
            .frame(maxWidth: UIScreen.main.bounds.width / 9, maxHeight: UIScreen.main.bounds.width / 8)
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
