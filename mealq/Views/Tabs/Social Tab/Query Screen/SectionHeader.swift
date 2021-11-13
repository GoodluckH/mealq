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
                .customFont(name: "Quicksand-SemiBold", style: .subheadline)
                .foregroundColor(.primary)
            Spacer()
            }
        .padding(.horizontal)
        .background(Color("QueryLoaderStartingColor"))
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(headerText: "my friends")
    }
}
