//
//  FakeSearchBar.swift
//  mealq
//
//  Created by Xipu Li on 11/18/21.
//

import SwiftUI

struct FakeSearchBar: View {
    var body: some View {
        VStack{
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2.weight(.bold))
                    .foregroundColor(Color("SearchBarSymbolColor"))
                Text("search for more friends")
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Spacer()
//                Image(systemName: "x.circle.fill")
//                    .scaleEffect(1)
//                    .foregroundColor(.gray)
//                    .symbolRenderingMode(.hierarchical)
                }
                .padding(.vertical, 7.0)
                .padding(.horizontal, 10.0)
                .background(.white)
                .clipShape(Capsule())
            }
            .padding(.horizontal)
        
    }
}

struct FakeSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        FakeSearchBar()
    }
}
