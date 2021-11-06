//
//  SectionHeader.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct SectionHeader: View {
    @State var headerText: String
    var body: some View {
        HStack{
            Text(headerText)
                .fontWeight(.ultraLight)
                .foregroundColor(.secondary)
            Spacer()
            }
        .padding(.horizontal)
        .background(.white)
        
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(headerText: "my friends")
    }
}
