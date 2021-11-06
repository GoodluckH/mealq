//
//  MealsView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct MealsView: View {

    @State var showModal: Bool = false
     var body: some View {
         NavigationView {
             Button(action: {
                 self.showModal = true
             }) {
                 Text("Tap me!")
             }
         }
         .navigationBarTitle(Text("Navigation!"))
         .overlay(self.showModal ? Color.green : nil)
     }
}

struct MealsView_Previews: PreviewProvider {
    static var previews: some View {
        MealsView()
    }
}
