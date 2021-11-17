//
//  SplashScreen.swift
//  mealq
//
//  Created by Xipu Li on 11/16/21.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack{
            Color(.red).zIndex(0)
            VStack{
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            
        }.ignoresSafeArea()
        
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
