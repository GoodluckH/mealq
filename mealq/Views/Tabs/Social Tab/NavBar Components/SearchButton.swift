//
//  SearchButton.swift
//  mealq
//
//  Created by Xipu Li on 11/13/21.
//

import SwiftUI

struct SearchButton: View {
    @FocusState var focusedField: Bool
    @State var showNavLinkView = false
    
    var body: some View {
        NavigationLink(destination: SearchScreen(focusedField: $focusedField, showNavLinkView: $showNavLinkView),
                         isActive: $showNavLinkView) {
            Image(systemName: "magnifyingglass")
                .onTapGesture{
                    showNavLinkView = true
                    focusedField = true
                }
                .customFont(name: "Quicksand-SemiBold", style: .title2)
                .foregroundColor(.primary)
        }
    }
}

struct SearchButton_Previews: PreviewProvider {
    static var previews: some View {
        SearchButton()
    }
}
