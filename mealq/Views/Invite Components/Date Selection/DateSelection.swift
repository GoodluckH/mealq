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
                    
                    VStack{
                        ZStack (alignment: .top) {

                        RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius / 2,
                                         style: .continuous)
                            .foregroundColor(Color("QueryLoaderStartingColor"))
                            

                          if selectedDate == day {
                              Rectangle()
                            .fill(getWeekdayColor(from: day))
                            .frame(minHeight: 8)
                            .aspectRatio(10/1, contentMode: .fit)
                            .clipped()
                              
                          }
                            
                            Text(getShortWeekday(from: day))
                             .font(Font.custom("Quicksand-Bold", size: 16))
                             .foregroundColor(Color("MyPrimary"))
                             .offset(y: selectedDate == day ? 12 : 9)

                    }
                        
                 
                         
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius/2))
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: selectedDate == day ? getWeekdayColor(from: day) : .gray, radius: Constants.roundedRectShadowRadius/2, y: Constants.roundedRectShadowYOffset)
                    .padding(Constants.tightStackSpacing * 2)
                        
                    
                    
                    
                    
                    
                    
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .fill(selectedDate == day ? .blue : Color("QueryLoaderStartingColor"))
//                            .shadow(color: getWeekdayColor(from: day), radius: selectedDate == day ? selectedShadowRadius : shadowRadius, y: shadowYOffset)
//                        Text("\(getShortWeekday(from:day))").foregroundColor(Color("MyPrimary"))
//                                                                                     
//                    } // ZStack
                }
                 .frame(height: buttonHeight)
                    
                   
            }
                //.padding()
                
        }.padding(.horizontal)
            .padding(.bottom)
    
    }
    
    
    private let buttonHeight: CGFloat = 60
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



