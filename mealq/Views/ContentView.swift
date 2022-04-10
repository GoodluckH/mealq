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
            .fullScreenCover(isPresented: $sessionStore.isAnon || !$sessionStore.agreedToEULA) {
                ZStack{
                    if sessionStore.localUser == nil {
                        UserLoginView()
                    } else if !sessionStore.agreedToEULA {
                        EULA()
                    }
                }
            }
    }
}



extension Binding where Value == Bool {

    static func ||(_ lhs: Binding<Bool>, _ rhs: Binding<Bool>) -> Binding<Bool> {
        return Binding<Bool>( get: { lhs.wrappedValue || rhs.wrappedValue },
                              set: {_ in })
    }
    
    static prefix func !(_ lhs: Binding<Bool>) -> Binding<Bool> {
        return Binding<Bool>(get:{ !lhs.wrappedValue },
                             set: { lhs.wrappedValue = !$0})
    }
}






























struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
