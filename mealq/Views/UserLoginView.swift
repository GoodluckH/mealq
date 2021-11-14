//
//  UserLoginView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import ActivityIndicatorView

struct UserLoginView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    
    var body: some View {
        
        
            if sessionStore.fbSigningIn {
              
                GeometryReader{ geometry in
                    VStack{
                        ActivityIndicatorView(isVisible: .constant(true), type: .equalizer)
                            .foregroundColor(.primary)
                            .frame(width: geometry.size.width/10, height: geometry.size.width/10, alignment: .center)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            } else {
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
                    
                    Button("Demo Login (for Apple employees only)") {
                        sessionStore.demoLogin()
                    }
            }
        }
            
        
            
        
    }
    
}










































struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}
