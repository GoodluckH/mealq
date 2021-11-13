//
//  SocialView.swift
//  mealq
//
//  Created by Xipu Li on 10/31/21.
//

import SwiftUI

struct SocialView: View {

    @EnvironmentObject var friendsManager: FriendsManager
    
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationView{
            VStack{
                HStack {
                    Text("activities")
                        .customFont(name: "Quicksand-SemiBold", style: .title1, weight: .black)
                    Spacer()
                    AlertButton()
                        .padding(.horizontal)
                    SearchButton()
                }
                .padding()
                    
          
                    // TODO: implement the friend activity stream
                    Text("no friend activity to display (coming up...)")
                        .frame(maxHeight: geometry.size.height, alignment: .top)
                        .ignoresSafeArea(.keyboard)
                        
                }.navigationBarHidden(true)
                    .navigationBarTitle(Text(""))
                }
            }
        }
    }



struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView().environmentObject(FriendsManager())
    }
}
