//
//  UserLoginView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI
import ActivityIndicatorView
import AuthenticationServices

struct UserLoginView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    
    var body: some View {
        
        
            if sessionStore.signingIn {
              
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
                            Spacer()
                            Image("fb.logo.white")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Text("continue with Facebook")
                                .font(Font.custom("Quicksand-Bold", size: 18))
                            Spacer()
                        }
                    }
                     .buttonStyle(mealqButtonStyle(clipShape: Capsule()))
                     .frame(width: UIScreen.main.bounds.width * 0.8, height: 60)
                    
                    
                    
                    Button(action: {
                        sessionStore.googleLogin(view: getRootViewController())
                    }) {
                        HStack{
                            Spacer()
                            Image("g.logo.color")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Text("continue with Google")
                                .font(Font.custom("Quicksand-Bold", size: 20))
                            Spacer()
                        }
                    }
                     .buttonStyle(mealqButtonStyle(clipShape: Capsule()))
                     .frame(width: UIScreen.main.bounds.width * 0.8, height: 60)

                    SignInWithAppleButton(.signIn, onRequest: sessionStore.appleLoginConfig, onCompletion: sessionStore.appleLoginHandler)
                        .buttonStyle(mealqButtonStyle(clipShape: Capsule()))
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 60)
                    

            }
        }
            
        
            
        
    }
    
}



extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
}








































struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}
