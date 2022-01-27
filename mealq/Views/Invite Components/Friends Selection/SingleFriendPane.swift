//
//  SingleFriendPane.swift
//  mealq
//
//  Created by Xipu Li on 11/18/21.
//

import SwiftUI

struct SingleFriendPane: View {
    var user: MealqUser
    @State var selected = false
    @Binding var selectedFriends: [MealqUser]
    let selectionLimit = 10
    var body: some View {
        GeometryReader { geo in
            
            Button (action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                if selected {
                Haptics.rigid()
                selected = false
                if let index = selectedFriends.firstIndex(of: user) {
                    selectedFriends.remove(at: index)
                }
                
            } else {
                if selectedFriends.count < selectionLimit {
                    Haptics.soft()
                    selected = true
                    selectedFriends.append(user)
                    
                }
            }}) {
                ZStack{
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color("QueryLoaderStartingColor"))
                        .shadow(color: selected ? .gray : selectedFriends.count < selectionLimit ? .gray : .red , radius: (selected || (selectedFriends.count >= selectionLimit)) ? selectedShadowRadius : shadowRadius, y: shadowYOffset)
                       
                    VStack{
                            ProfilePicView(picURL: user.normalPicURL)
                            .frame(width: geo.size.width/imageScaleFactor, height: geo.size.width/imageScaleFactor, alignment: .center)
                            .overlay(
                                ZStack{
                                    if selected {
                                        Circle().fill(.white).opacity(overlayCircleOpacity)
                                        Image(systemName: "checkmark").font(font(in: geo.size, by: checkmarkScaleFactor))
                                            .foregroundColor(.black)
                                            .font(.largeTitle)
                                    }
                                }
                            )
                            .position(x: geo.size.width / 2, y: geo.size.height/2.4)
                            
                            Text(user.fullname).bold()
                                .foregroundColor(Color("MyPrimary"))
                                .font(font(in: geo.size, by: 1))
                                .minimumScaleFactor(minFontScaleFactor)
                                .lineLimit(1)
                                .padding(.horizontal)
                                .position(x: geo.size.width / 2, y: geo.size.height/3)
                                
                    } // Vstack
               
                
                
                } // ZStack
            }
        } // geometryReader

    }
    
    
    
    
    
    
    
    
    
    
    
    
    private let cornerRadius: CGFloat = 10
    private let shadowRadius: CGFloat = 7
    private let selectedShadowRadius: CGFloat = 3
    private let shadowYOffset: CGFloat = 1
    private let fontScaleFactor: CGFloat = 0.2
    private let minFontScaleFactor: CGFloat = 0.07
    private let imageScaleFactor: CGFloat = 1.3
    private let checkmarkScaleFactor: CGFloat = 3
    private let overlayCircleOpacity: CGFloat = 0.8
    
    private func font(in size: CGSize, by multiplier: CGFloat) -> Font {
        Font.custom("Quicksand-SemiBold", size: fontScaleFactor * min(size.width, size.height) * multiplier)
    }

}


//
//struct SingleFriendPane_Previews: PreviewProvider {
//    static let newUser = MealqUser(id: "sdfasdfdsfsd", fullname: "John Jomme", email: "slfsd@sdf.com")
//    @State static var selectedFriends: [MealqUser] = []
//    static var previews: some View {
//        SingleFriendPane(user: newUser, selectedFriends: selectedFriends)
//    }
//}
