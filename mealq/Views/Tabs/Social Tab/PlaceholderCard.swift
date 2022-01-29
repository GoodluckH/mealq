//
//  PlaceholderCard.swift
//  mealq
//
//  Created by Xipu Li on 1/28/22.
//

import SwiftUI
import Lottie

struct PlaceholderCard: View {
    @State var animate = false
    var body: some View {
        VStack {
           ZStack{
               VStack (alignment: .leading){
                HStack{
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                    VStack(alignment: .leading, spacing: Constants.tightStackSpacing) {
                        Rectangle().frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 25)
                        Rectangle().frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 35)
                    }
                    
                    Spacer()
                }
                
                Rectangle().frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 20).padding(.vertical, Constants.tightStackSpacing)
                
                HStack {
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                }
            }.foregroundColor(.gray.opacity(0.2)).padding()
            
            VStack (alignment: .leading){
                HStack{
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 10, height: UIScreen.main.bounds.width / 10)
                    VStack(alignment: .leading, spacing: Constants.tightStackSpacing) {
                        Rectangle().frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 25)
                        Rectangle().frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 35)
                    }
                    
                    Spacer()
                }
                
                Rectangle().frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 20).padding(.vertical, Constants.tightStackSpacing)
                
                HStack {
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                    Circle()
                        .frame(width: UIScreen.main.bounds.width / 20, height: UIScreen.main.bounds.width / 20)
                }
            }.foregroundColor(.gray.opacity(0.6)).padding()
                .mask(
                    Rectangle().fill(.gray.opacity(0.6))
                        .rotationEffect(.init(degrees: 70))
                        .offset(x: animate ? 1000 : -400)
                )
               
           }
            
            
        }
            .background(
            RoundedRectangle(cornerRadius: Constants.roundedRectCornerRadius)
                .foregroundColor(Color("QueryLoaderStartingColor"))
                .shadow(color: .gray, radius: Constants.roundedRectSelectedShadowRadius)
        )
          
            .onAppear {
                DispatchQueue.main.async{
                    self.animate = false
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        self.animate.toggle()
                    }
                     
                }
            }
    }
}

struct PlaceholderCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderCard()
    }
}
