//
//  SmartTimeStamp.swift
//  mealq
//
//  Created by Xipu Li on 1/6/22.
//


import SwiftUI

struct SmartTimeStamp: View {
    
    var date: String
    var timeStamp: Date
    var body: some View {
        HStack{
            if date == "FULLDATE" {
                Text(timeStamp, style: .date).fontWeight(.bold)
            }
            else  {
                Text(date).fontWeight(.bold)
                Text(timeStamp, style: .time)
            }
        }
        .font(.custom("Quicksand-Medium", size: 12))
        .padding()
        .foregroundColor(.gray)
    }
}

//struct SmartTimeStamp_Previews: PreviewProvider {
//    static var previews: some View {
//        SmartTimeStamp()
//    }
//}
