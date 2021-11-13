//
//  ContentView.swift
//  mealq
//
//  Created by Xipu Li on 10/30/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        MainAppView()
            .fullScreenCover(isPresented: $sessionStore.isAnon) {
                ZStack{
                    UserLoginView()
                }
            }
    }
}




































struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
