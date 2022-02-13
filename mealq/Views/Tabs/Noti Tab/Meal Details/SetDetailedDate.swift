//
//  SetDetailedDate.swift
//  mealq
//
//  Created by Xipu Li on 2/12/22.
//

import SwiftUI

struct SetDetailedDate: View {
    @ObservedObject var sharedDatePickerViewModel = DatePickerViewModel.sharedDatePickerViewModel
    var mealID: String
    var body: some View {
            Button(action: {
                DispatchQueue.main.async {
                    Haptics.soft()
                }
                sharedDatePickerViewModel.currentMeal = mealID
                sharedDatePickerViewModel.showDatePicker = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    sharedDatePickerViewModel.animate = true
                }
                
               
            }) {
                Circle()
                    .fill(Color("MyPrimary"))
                    .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                    .overlay {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.white)
                            
                    }.shadow(color: .gray, radius: Constants.roundedRectCornerRadius)
            }
    }
}

//struct SetDetailedDate_Previews: PreviewProvider {
//    static var previews: some View {
//        SetDetailedDate()
//    }
//}
