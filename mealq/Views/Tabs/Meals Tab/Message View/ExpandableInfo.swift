//
//  ExpandableInfo.swift
//  mealq
//
//  Created by Xipu Li on 2/19/22.
//

import SwiftUI

struct ExpandableInfo: View {
    @Binding var meal: Meal?
    @State var expand = false
    @Namespace var nspace
    
    var body: some View {

       if let meal = meal {
    
        HStack{
            Spacer()
            VStack {
            if expand {
                VStack {
                    if let specificDate = meal.specificDate {
                        SpecificCalendarBadge(specificDate: specificDate, weekday: meal.weekday, mealID: meal.id)
                            .padding()
                    } else {
                        SetDetailedDate(mealID: meal.id)
                            .padding()
                    }
                
                    Text("").padding()
                    Button(action: {
                        withAnimation{expand = false}
                    }) {
                        Image(systemName: "chevron.up").foregroundColor(Color("MyPrimary"))
                    }.matchedGeometryEffect(id: "chevron", in: nspace)
                        .padding(.bottom, Constants.tightStackSpacing * 2)
                }
            } else {
                
                Button(action: {
                    withAnimation{expand = true}
                }) {
                    Image(systemName: "chevron.down").foregroundColor(Color("MyPrimary"))
                        
                }.matchedGeometryEffect(id: "chevron", in: nspace)
                    .padding(.bottom, Constants.tightStackSpacing)
                    .offset(y: -Constants.tightStackSpacing)
                
            }
        }
            Spacer()
        }
        .background {
                Color("QueryLoaderStartingColor").background(.ultraThinMaterial)

        }
        .clipShape(RoundedCorners(cornerRadii: Constants.expandableInfoCornerRadius))
        .shadow(color: .gray, radius: expand ? Constants.roundedRectShadowRadius : Constants.roundedRectSelectedShadowRadius)
       
       }
            
                
                


        
        
    }
}

//struct ExpandableInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpandableInfo()
//    }
//}
