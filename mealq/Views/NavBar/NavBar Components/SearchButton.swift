//
//  SearchButton.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI


struct SearchButton: View {
    @State var showNavLinkView = false

    var body: some View {
        NavigationLink(destination: SearchScreen(showNavLinkView: $showNavLinkView)
                        ,isActive: $showNavLinkView) {
            
            Button(action: {
                var transaction = Transaction()
                transaction.disablesAnimations  = true
                withTransaction(transaction) {
                    showNavLinkView = true
                }
                
                
            }) {
                 Image(systemName: "magnifyingglass")
                    .customFont(name: "Quicksand-SemiBold", style: .title2)
                    .foregroundColor(.primary)
            }
        }
            
    }
}

//struct SearchButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchButton()
//    }
//}
