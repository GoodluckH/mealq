//
//  MealDatePicker.swift
//  mealq
//
//  Created by Xipu Li on 2/12/22.
//

import SwiftUI

struct MealDatePicker: View {
    @ObservedObject var sharedDatePickerViewModel = DatePickerViewModel.sharedDatePickerViewModel
    @EnvironmentObject var mealsManager: MealsManager
    var body: some View {
   

            
            // Datepicker and the confirmation button
            VStack {
                DatePicker(
                    "Meal Date",
                    selection: $sharedDatePickerViewModel.date
                ).accentColor(Color("DatePickerAccent"))
                    .padding(.top).padding(.horizontal)
                    .datePickerStyle(.graphical)
                    .background{
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color("QueryLoaderStartingColor"))
                            .shadow(color: .gray, radius: Constants.roundedRectCornerRadius)
                    }.offset(y: sharedDatePickerViewModel.animate ? 0 : -30)
                    .opacity(sharedDatePickerViewModel.animate ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.5).delay(0.1), value: sharedDatePickerViewModel.animate)
                    
                Button(action: {
                    
                    DispatchQueue.main.async {
                        Haptics.soft()
                    }
                    sharedDatePickerViewModel.showDatePicker = false                    
                    mealsManager.setSpecificDate(on: sharedDatePickerViewModel.date, for: sharedDatePickerViewModel.currentMeal)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        sharedDatePickerViewModel.animate = false
                    }
   
                        // set the date on the server to selected date, and then set view model date to
                }
                ) {
                    RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius)
                        .fill(Color("MyPrimary"))
                        .frame(width: UIScreen.main.bounds.width / 2.7, height: UIScreen.main.bounds.width / 8)
                        .overlay {
                            Text("confirm date")
                                .customFont(name: "Quicksand-SemiBold", style: .title3)
                                .foregroundColor(Color("QueryLoaderStartingColor"))
                        }
                }
                .offset(y: sharedDatePickerViewModel.animate ? 0 : 30)
                .opacity(sharedDatePickerViewModel.animate ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.5).delay(0.2), value: sharedDatePickerViewModel.animate)
                .shadow(color: .gray, radius: Constants.roundedRectCornerRadius)
                .padding()
            }.padding()
        
        
            
    }
}
extension View {
  @ViewBuilder func applyTextColor(_ color: Color) -> some View {
    if UITraitCollection.current.userInterfaceStyle == .light {
      self.colorInvert().colorMultiply(color)
    } else {
      self.colorMultiply(color)
    }
  }
}
