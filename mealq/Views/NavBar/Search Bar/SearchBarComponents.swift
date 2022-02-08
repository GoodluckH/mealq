//
//  SearchBarSymbols.swift
//  mealq
//
//  Created by Xipu Li on 11/3/21.
//

import SwiftUI
import Introspect

struct SearchBarSymbols: View {
    @Binding var searchText: String
    @Binding var showNavLinkView: Bool
    var staticSearch: Bool?
    var body: some View {
        if staticSearch ?? false {
       
            Image(systemName: "magnifyingglass")
                .font(.title2.weight(.bold))
                .foregroundColor(Color("SearchBarSymbolColor"))
        } else {
            Button(action: {
                   searchText = ""
                   showNavLinkView = false
            }){
            Image(systemName: "arrow.left")
                .font(.title2.weight(.bold))
            }
            .foregroundColor(Color("SearchBarSymbolColor"))
        }

        
    }
}

struct CustomTextField: View {
    @Binding var searchText: String
    @FocusState private var focusedField: Bool

    var body: some View {
        TextField("", text: $searchText)
            .placeholder("search people", when: searchText.isEmpty)
                .frame(alignment: .leading)
                .focused($focusedField)
                .foregroundColor(Color("SearchBarSymbolColor"))
                .accentColor(Color("SearchBarSymbolColor"))
                .disableAutocorrection(true)
                .onAppear{
                    // TODO: optimize for keyboard popup when come back from the navigationview
                        focusedField = true
                }
    }
}


struct CancelButton: View {
    @Binding var searchText: String
    
    var body: some View {
        if !searchText.isEmpty {
            Button(action: {searchText = ""}){
            Image(systemName: "x.circle.fill")
                .scaleEffect(1)
                .foregroundColor(.gray)
                .symbolRenderingMode(.hierarchical)
            }
        }
    }
}



extension View {
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        textColor: Color = .gray) -> some View {

        placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(textColor) }
    }
}




extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

//
//struct MyTextField: UIViewRepresentable {
//    @Binding var text: String
//    let placeholder: String
//
//    class Coordinator: NSObject, UITextFieldDelegate {
//        @Binding var text: String
//        var becameFirstResponder = false
//
//        init(text: Binding<String>) {
//            self._text = text
//        }
//
//        func textFieldDidChangeSelection(_ textField: UITextField) {
//            text = textField.text ?? ""
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(text: $text)
//    }
//
//    func makeUIView(context: Context) -> some UIView {
//        let textField = UITextField()
//        textField.delegate = context.coordinator
//        textField.placeholder = placeholder
//        textField.textColor = UIColor(Color("SearchBarSymbolColor"))
//        return textField
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        if  !context.coordinator.becameFirstResponder {
//            uiView.becomeFirstResponder()
//            context.coordinator.becameFirstResponder = true
//        }
//    }
//}
