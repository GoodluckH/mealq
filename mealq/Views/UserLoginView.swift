//
//  UserLoginView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct UserLoginView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    
    var body: some View {
            VStack {
                Button(action: {
                    sessionStore.facebookLogin()
                }) {
                    HStack{
                        Image("fb.logo.white")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text("continue with Facebook")
                            .font(Font.custom("Quicksand-Bold", size: 20))
                    }
                }
                 .buttonStyle(mealqButtonStyle(clipShape: Capsule()))
                 .frame(height: 60)
                
                Button("Demo Login (for Apple reviewers)") {
                    sessionStore.demoLogin()
                }
            }
        
    }
    
}










































struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}
