//
//  DateSelection.swift
//  mealq
//
//  Created by Xipu Li on 12/5/21.
//

import SwiftUI

struct DateSelection: View {
    @Binding var selectedDate: Int?
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { day in
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    if selectedDate == day {
                        Haptics.rigid()
                        selectedDate = nil
                    } else {
                        Haptics.soft()
                        selectedDate = day
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(selectedDate == day ? .blue : Color("QueryLoaderStartingColor"))
                            .shadow(color: .gray, radius: selectedDate == day ? selectedShadowRadius : shadowRadius, y: shadowYOffset)
                        Text("\(getWeekDayFrom(day))").foregroundColor(Color("MyPrimary"))
                        
                    } // ZStack
                }
                .frame(height: buttonHeight)
                    
                   
            }
                //.padding()
                
        }.padding()
    
    }
    
    
    private let buttonHeight: CGFloat = 40
    private let cornerRadius: CGFloat = 10
    private let shadowRadius: CGFloat = 7
    private let selectedShadowRadius: CGFloat = 3
    private let shadowYOffset: CGFloat = 1
}

//struct DateSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        DateSelection(selectedDate: )
//    }
//}


private func getWeekDayFrom(_ number: Int) -> String {
    switch number {
    case 1: return "mon";
    case 2: return "tue";
    case 3: return "wed";
    case 4: return "thur";
    case 5: return "fri";
    case 6: return "sat";
    case 7: return "sun";
    default: return "";
    }
}
