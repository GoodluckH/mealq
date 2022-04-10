//
//  EULA.swift
//  mealq
//
//  Created by Xipu Li on 4/10/22.
//

import SwiftUI

struct EULA: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        VStack {
            ScrollView {
                VStack (alignment: .center) {
                    Text("Terms of Service\n").font(.title)
                    
                    Text("By signing up for mealq, you accept our [Privacy Policy](https://github.com/GoodluckH/mealq/blob/main/Privacy%20Policy.md) and agree NOT to:\n\n*• Use our service to send spam, abuse or scam users.*\n\n*• Generate objectionable contents.*\n\nWe reserve the right to update these Terms of Service later.\n\nYou must accept these Terms of Service to use mealq.")
                    
                }
                
            }.padding()
            Spacer()
            HStack{
                Spacer()
                Spacer()
                Button(action:{
                    sessionStore.agreedToEULA = false
                    sessionStore.signOut()
                }) {
                    Text("Decline")
                }
                Spacer()
                Button(action:{
                    sessionStore.agreedToEULA = true
                }) {
                    Text("Accept").fontWeight(.bold)
                }
                Spacer()
                Spacer()
                
            }
        }

        
    }
}

