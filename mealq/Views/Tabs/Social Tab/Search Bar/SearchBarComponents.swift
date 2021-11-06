//
//  SearchBarSymbols.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI

struct SearchBarSymbols: View {
    @Binding var searchText: String
    @Binding var showSearchScreen: Bool
    @FocusState.Binding var focusedField: Bool
    
    var body: some View {
        if !showSearchScreen {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.bold))
                .foregroundColor(Color("SearchBarSymbolColor"))
                .onTapGesture {
                    focusedField = true
                    showSearchScreen = true
                }
        } else {
            Button(action: {
                showSearchScreen = false
                focusedField = false
                searchText = ""
            }){
            Image(systemName: "arrow.left")
                .font(.body.weight(.bold))
            }
            .foregroundColor(Color("SearchBarSymbolColor"))
        }
    }
}

struct CustomTextField: View {
    @Binding var searchText: String
    @Binding var showSearchScreen: Bool
    @FocusState.Binding var focusedField: Bool

    var body: some View {
        TextField("friend name", text: $searchText)
                .frame(alignment: .leading)
                .focused($focusedField)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2)){
                    focusedField = true
                    showSearchScreen = true}
                }
                .foregroundColor(Color("SearchBarSymbolColor"))
                .accentColor(Color("SearchBarSymbolColor"))
                .disableAutocorrection(true)
    }
}


struct CancelButton: View {
    @Binding var searchText: String
    
    var body: some View {
        if !searchText.isEmpty {
            Button(action: {searchText = ""}){
            Image(systemName: "x.circle.fill")
                .scaleEffect(0.8)
                .foregroundColor(.gray)
                .symbolRenderingMode(.hierarchical)
            }
        }
    }
}


