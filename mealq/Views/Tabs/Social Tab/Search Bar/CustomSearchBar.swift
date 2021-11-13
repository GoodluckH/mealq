//
//  CustomSearchBar.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    @FocusState.Binding var focusedField: Bool
    @Binding var showNavLinkView: Bool
    var body: some View {
        VStack{
            HStack {
                SearchBarSymbols(searchText: $searchText, focusedField: $focusedField, showNavLinkView: $showNavLinkView)
                CustomTextField(searchText: $searchText, focusedField: $focusedField)
                CancelButton(searchText: $searchText)
                }
                .padding(.vertical, 8.0)
                .padding(.horizontal, 10.0)
                .background(Color("SearchBarBackgroundColor"))
                .clipShape(Capsule())
            }
            .padding(.horizontal)
         }
    }


