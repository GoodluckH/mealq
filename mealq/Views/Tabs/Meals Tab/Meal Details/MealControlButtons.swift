//
//  MealControlButtons.swift
//  mealq
//
//  Created by Xipu Li on 1/1/22.
//

import SwiftUI


struct MealControlButtons: View {
    @State var userStatus: [MealqUser: String]
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var mealsManager: MealsManager
    @State private var showUnmealSheet = false
    var meal: Meal
    var body: some View {
        GeometryReader { geometry in
          
            if userStatus[sessionStore.localUser!] == "pending" {
                HStack{
                    Spacer()
                
                    Button(action: {
                        // TODO: sdflsaf\
                        mealsManager.updateMealStatus(to: "declined", of: meal.id)
                    }) {
                      HStack{
                          Image(systemName: "xmark").customFont(name: "Quicksand-SemiBold", style: .headline, weight: .bold)
                      }}
                    .foregroundColor(.white)
                    .padding(.vertical, 10.0)
                    .frame(width: geometry.size.width/8)
                    .background(Color.red)
                    .clipShape(Circle())
                    Button(action: {
                    // TODO: sdflsaf
                        mealsManager.updateMealStatus(to: "accepted", of: meal.id)
                    }) {
                      HStack{
                          Image(systemName: "checkmark")
                          Text("accept meal")
                      }}
                    .customFont(name: "Quicksand-SemiBold", style: .headline, weight: .bold)
                       .foregroundColor(.white)
                       .padding(.vertical, 10.0)
                       .frame(width: geometry.size.width/2)
                       .background(Color.green)
                       .clipShape(Capsule())
                    Spacer()
                }
            } else if sessionStore.localUser != meal.from {
                HStack{

                    Spacer()
                    Button("accepted") {showUnmealSheet = true}
                    .customFont(name: "Quicksand-SemiBold", style: .headline, weight: .bold)
                   .foregroundColor(.blue)
                   .padding(.vertical, 10.0)
                   .frame(width: geometry.size.width/2)
                   .background(Capsule().strokeBorder(Color.blue, lineWidth: 2))
                   .confirmationDialog("You sure you are not going anymore? This will change your status to 'declined'.", isPresented: $showUnmealSheet, titleVisibility: .visible) {
                       Button("decline accepted meal", role: .destructive) {
                           mealsManager.updateMealStatus(to: "declined", of: meal.id)
                       }
                   }
                    Spacer()
                }
            }
            
            
            
            
        }.frame(height: UIScreen.main.bounds.height / 12)

    }
}

