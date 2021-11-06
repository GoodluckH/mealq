//
//  CustomSearchBar.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    @Binding var showSearchScreen: Bool
    @FocusState.Binding var focusedField: Bool
    
    var body: some View {
        VStack{
            HStack {
                SearchBarSymbols(searchText: $searchText,showSearchScreen: $showSearchScreen,focusedField: $focusedField)
                CustomTextField(searchText: $searchText, showSearchScreen: $showSearchScreen, focusedField: $focusedField)
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


